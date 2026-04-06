//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

final class YoteiScheduleUICollectionView: UICollectionView {
    private enum Constants {
        static var sectionInsets: UIEdgeInsets {
            .init(top: 6, left: 16, bottom: 8, right: 16)
        }
    }

    private let layout: YoteiScheduleCollectionViewLayout

    private var lastUserScrollOffset: CGFloat = 0
    private var focusedDate: Date?

    private let focusedDateUpdate: (Date) -> Void
    private let factory: YoteiScheduleCollectionViewFactory
    private weak var calendarDelegate: YoteiDelegate?
    private var items: [YoteiScheduleViewModel] = []
    private var sections: [Date] = []
    private var sectionPosition: (section: Date, verticalOffset: CGFloat)?
    private var isScrollDetectionDisabled = false
    private var autoUpdateTask: Task<Void, Never>?

    private var diffableDataSource: YoteiScheduleDataSource!

    private let diffableDataStorage = DiffableDataStorage<
        Date,
        YoteiScheduleViewModel
    >()

    init(
        factory: YoteiScheduleCollectionViewFactory,
        delegate: YoteiDelegate?,
        focusedDateUpdate: @escaping (Date) -> Void
    ) {
        self.factory = factory
        calendarDelegate = delegate
        self.focusedDateUpdate = focusedDateUpdate
        layout = YoteiScheduleCollectionViewLayout()
        super.init(frame: .zero, collectionViewLayout: layout)

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        autoUpdateTask?.cancel()
    }

    private func setup() {
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self

        let eventCellRegistration = factory.eventCellRegistration()
        let emptyCellRegistration = factory.emptyCellRegistration()
        let loadingCellRegistration = factory.loadingCellRegistration()
        let headerRegistration = factory.headerRegistration { [unowned self] indexPath in
            diffableDataStorage.section(
                in: diffableDataSource.snapshot(),
                for: indexPath.section
            ) ?? Date()
        }

        diffableDataSource = YoteiScheduleDataSource(
            collectionView: self
        ) { [unowned self] collectionView, indexPath, id -> UICollectionViewCell in
            guard let viewModel = diffableDataStorage.item(for: id) else {
                return UICollectionViewCell()
            }

            switch viewModel.kind {
            case let .event(event):
                return collectionView.dequeueConfiguredReusableCell(
                    using: eventCellRegistration,
                    for: indexPath,
                    item: (viewModel.date, event)
                )
            case .empty:
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: viewModel.date
                )
            case .loading:
                return collectionView.dequeueConfiguredReusableCell(
                    using: loadingCellRegistration,
                    for: indexPath,
                    item: viewModel.date
                )
            }
        }

        diffableDataSource.supplementaryViewProvider = .init { collectionView, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }

    private func sortedVisibleSections() -> [IndexPath] {
        indexPathsForVisibleSupplementaryElements(
            ofKind: UICollectionView.elementKindSectionHeader
        ).sorted()
    }

    private func saveCurrentPosition() {
        let indexPath = sortedVisibleSections().first

        guard
            let indexPath,
            let date = diffableDataStorage.section(
                in: diffableDataSource.snapshot(),
                for: indexPath.section
            ),
            let sectionFrame = layout.absoluteLayoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            )?.frame
        else {
            if let focusedDate {
                sectionPosition = (focusedDate, 0)
            }
            return
        }

        let offset = sectionFrame.minY - contentOffset.y
        sectionPosition = (date, offset)
    }

    private func startCollectionAutoupdate() {
        // redraw visible cells every minute so reflect time change on screen
        autoUpdateTask?.cancel()
        autoUpdateTask = Task { @MainActor in
            while !Task.isCancelled {
                await diffableDataSource.applySnapshotUsingReloadData(diffableDataSource.snapshot())
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }

    private func apply(data: [(section: Date, items: [YoteiScheduleViewModel])]) {
        let sections = data.map(\.section)
        let items = data.map(\.items).flatMap(\.self)
        guard sections != self.sections || items != self.items else {
            return
        }

        saveCurrentPosition()

        // animation disabled, because cells animating from bottom for some reason.
        // layout.initialLayoutAttributesForAppearingItem does not help. Investigate it later
        let shouldAnimate = false // sections == self.sections
        self.sections = sections
        self.items = items
        diffableDataSource.apply(
            snapshot: diffableDataStorage.apply(data: data),
            animatingDifferences: shouldAnimate
        )

        startCollectionAutoupdate()
    }

    private func apply(focusedDate: Date) {
        guard focusedDate != self.focusedDate else {
            return
        }

        self.focusedDate = focusedDate
        sectionPosition = (focusedDate, 0)

        if
            let sectionIndex = diffableDataSource.snapshot().indexOfSection(focusedDate.id),
            let sectionFrame = layout.absoluteLayoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(row: 0, section: sectionIndex)
            )?.frame
        {
            setContentOffset(CGPoint(x: 0, y: sectionFrame.minY), animated: true)
        }
    }

    func apply(data: YoteiScheduleViewData) {
        if focusedDate == nil {
            focusedDate = data.focusedDate
        }

        apply(data: data.data)
        apply(focusedDate: data.focusedDate)
    }
}

extension YoteiScheduleUICollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = diffableDataStorage.item(
            in: diffableDataSource.snapshot(),
            for: indexPath
        ) else {
            return false
        }

        return switch viewModel.kind {
        case .empty, .loading: false
        case .event: true
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = diffableDataStorage.item(
            in: diffableDataSource.snapshot(),
            for: indexPath
        ) else {
            return
        }

        switch viewModel.kind {
        case let .event(item):
            calendarDelegate?.calendarDidSelectEvent(with: item.id)
        case .empty, .loading:
            ()
        }
    }

    func collectionView(
        _: UICollectionView,
        targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint
    ) -> CGPoint {
        let snapshot = diffableDataSource.snapshot()
        guard
            let sectionPosition,
            let firstSectionIdentifier = snapshot.sectionIdentifiers.first,
            let lastSectionIdentifier = snapshot.sectionIdentifiers.last
        else {
            return proposedContentOffset
        }

        let sectionIndex = if let sectionIndex = snapshot.indexOfSection(sectionPosition.section.id) {
            // if saved section exists after update, set offset on it
            sectionIndex
        } else if firstSectionIdentifier > sectionPosition.section.id {
            // if saved section does not exist, set offset on the first or last element of a new data set,
            // so we can perform a scroll animation to the target section with setContentOffset
            snapshot.indexOfSection(firstSectionIdentifier)
        } else {
            snapshot.indexOfSection(lastSectionIdentifier)
        }

        if
            let sectionIndex,
            let sectionFrame = layout.absoluteLayoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(row: 0, section: sectionIndex)
            )?.frame
        {
            return CGPoint(
                x: proposedContentOffset.x,
                y: sectionFrame.minY - sectionPosition.verticalOffset
            )
        }

        return proposedContentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isUserScrolling = scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating
        guard
            // data source update can trigger `scrollViewDidScroll` method in the middle of `apply` method
            // with outdated contentOffset
            !diffableDataSource.isUpdating,
            isUserScrolling,
            let activeSectionIndex = sortedVisibleSections().first?.section,
            let date = diffableDataStorage.section(in: diffableDataSource.snapshot(), for: activeSectionIndex)
        else {
            return
        }
        lastUserScrollOffset = scrollView.contentOffset.y

        if date != focusedDate {
            focusedDate = date
            focusedDateUpdate(date)
        }
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = diffableDataStorage.item(
            in: diffableDataSource.snapshot(),
            for: indexPath
        ) else {
            return .zero
        }

        let width = bounds.width - Constants.sectionInsets.left - Constants.sectionInsets.right

        switch viewModel.kind {
        case let .event(event):
            return CGSize(width: width, height: event.isAllDay ? 16 : 52)
        case .empty, .loading:
            return CGSize(width: width, height: 52)
        }
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        referenceSizeForHeaderInSection _: Int
    ) -> CGSize {
        CGSize(width: bounds.width, height: 28)
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        Constants.sectionInsets
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        8
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        8
    }
}
