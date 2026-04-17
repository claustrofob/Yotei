//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import UIKit

// it is possible to implement this layout with CompositionalLayout,
// but for calendar scroll to work properly, it is required that inside `targetContentOffsetForProposedContentOffset` delegate method
// we can get updated `layoutAttributesForSupplementaryElement`. Compositional layout returns old attributes in that case.
final class YoteiScheduleCollectionViewLayout: UICollectionViewLayout {
    private var lastWidth: CGFloat = -1
    private var attributeSectionIndexOffset: [Int] = []
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var sectionLayoutAttributes: [UICollectionViewLayoutAttributes] = []

    private var contentSize: CGSize = .zero

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    override func prepare() {
        super.prepare()

        guard
            let collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            lastWidth != collectionView.bounds.width
        else {
            return
        }

        lastWidth = collectionView.bounds.width
        attributeSectionIndexOffset = []
        layoutAttributes = []
        sectionLayoutAttributes = []

        var fullRect: CGRect = .zero
        var verticalOffset: CGFloat = 0

        let numberOfSections = collectionView.numberOfSections
        for sectionIndex in 0 ..< numberOfSections {
            attributeSectionIndexOffset.append(layoutAttributes.count)

            let numberOfItems = collectionView.numberOfItems(inSection: sectionIndex)

            let sectionInsets = delegate.collectionView?(
                collectionView,
                layout: self,
                insetForSectionAt: sectionIndex
            ) ?? .zero
            let interitemSpacing = delegate.collectionView?(
                collectionView,
                layout: self,
                minimumInteritemSpacingForSectionAt: sectionIndex
            ) ?? 0
            let sectionIndexPath = IndexPath(row: 0, section: sectionIndex)
            let sectionAttribute = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: sectionIndexPath
            )
            let sectionSize = delegate.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForHeaderInSection: sectionIndex
            ) ?? .zero

            let sectionOrigin = CGPoint(x: 0, y: verticalOffset)
            sectionAttribute.frame = CGRect(origin: sectionOrigin, size: sectionSize)
            sectionLayoutAttributes.append(sectionAttribute)
            fullRect = fullRect.union(sectionAttribute.frame)
            verticalOffset = sectionAttribute.frame.maxY + sectionInsets.top

            for itemIndex in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                let itemAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let itemSize = delegate.collectionView?(
                    collectionView,
                    layout: self,
                    sizeForItemAt: indexPath
                ) ?? .zero
                let itemOrigin = CGPoint(x: sectionInsets.left, y: verticalOffset)
                itemAttribute.frame = CGRect(origin: itemOrigin, size: itemSize)

                fullRect = fullRect.union(itemAttribute.frame)
                layoutAttributes.append(itemAttribute)

                verticalOffset = itemAttribute.frame.maxY
                verticalOffset += itemIndex != (numberOfItems - 1) ? interitemSpacing : 0
            }

            verticalOffset += sectionInsets.bottom
        }

        contentSize = fullRect.size
    }

    private func stickyLayoutAttributesForSupplementaryView(basedOn attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard
            let collectionView,
            attributes.frame.minY < collectionView.contentOffset.y,
            let elementKind = attributes.representedElementKind
        else {
            return attributes
        }
        let indexPath = attributes.indexPath
        let maxY = sectionLayoutAttributes[safe: indexPath.section + 1]?.frame.minY ?? .greatestFiniteMagnitude

        let adjustedAttributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: elementKind,
            with: indexPath
        )
        adjustedAttributes.frame = attributes.frame
        adjustedAttributes.frame.origin.y = min(collectionView.contentOffset.y, maxY - attributes.frame.height)
        adjustedAttributes.zIndex = 1
        return adjustedAttributes
    }

    override func layoutAttributesForElements(in _: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes + sectionLayoutAttributes.map {
            stickyLayoutAttributesForSupplementaryView(basedOn: $0)
        }
    }

    override func layoutAttributesForSupplementaryView(ofKind _: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        stickyLayoutAttributesForSupplementaryView(basedOn: sectionLayoutAttributes[indexPath.section])
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < attributeSectionIndexOffset.count else {
            return nil
        }

        let index = attributeSectionIndexOffset[indexPath.section] + indexPath.item
        guard index < layoutAttributes.count else {
            return nil
        }

        return layoutAttributes[index]
    }

    // this should always be true for `invalidationContext(forBoundsChange newBounds: CGRect)` to be called
    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)

        var sectionIndexPathsToUpdate = sectionLayoutAttributes.filter {
            $0.frame.minY >= newBounds.minY && $0.frame.maxY <= newBounds.maxY
        }.map(\.indexPath).sorted()

        // add a section that is before the first one, because it can be the sticky header
        if let first = sectionIndexPathsToUpdate.first, first.section > 0 {
            sectionIndexPathsToUpdate.append(IndexPath(row: 0, section: first.section - 1))
        }

        context.invalidateSupplementaryElements(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: sectionIndexPathsToUpdate
        )
        return context
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            lastWidth = -1
        }
    }

    // `layoutAttributesForSupplementaryView` returns sticky header position, which may differ from the absolute section position
    // Absolute position is required for setting proper contentOffset when focusedDate is updated.
    func absoluteLayoutAttributesForSupplementaryView(
        ofKind _: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        sectionLayoutAttributes[safe: indexPath.section]
    }
}
