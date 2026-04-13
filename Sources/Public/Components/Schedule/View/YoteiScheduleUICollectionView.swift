//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

final class YoteiScheduleUICollectionView<ViewFactory: YoteiScheduleViewFactoryProtocol>: UICollectionView, UICollectionViewDelegateFlowLayout {
    private let layout: YoteiScheduleCollectionViewLayout

    private var lastUserScrollOffset: CGFloat = 0
    private var focusedDate: Date?

    private let focusedDateUpdate: (Date) -> Void
    private let calendar: Calendar
    private let viewFactory: ViewFactory
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
        calendar: Calendar,
        viewFactory: ViewFactory,
        delegate: YoteiDelegate?,
        focusedDateUpdate: @escaping (Date) -> Void
    ) {
        self.calendar = calendar
        self.viewFactory = viewFactory
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

        let eventCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewCell, (Date, YoteiEvent)
        > { [viewFactory, calendar] cell, _, event in
            cell.contentConfiguration = UIHostingConfiguration {
                viewFactory.eventCellView(
                    date: event.0,
                    event: event.1,
                    calendar: calendar
                )
            }.margins(.all, 0)
        }
        let allDayEventCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewCell, (Date, YoteiEvent)
        > { [viewFactory, calendar] cell, _, event in
            cell.contentConfiguration = UIHostingConfiguration {
                viewFactory.allDayEventCellView(
                    date: event.0,
                    event: event.1,
                    calendar: calendar
                )
            }.margins(.all, 0)
        }
        let emptyCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewCell, Date
        > { [viewFactory] cell, _, date in
            cell.contentConfiguration = UIHostingConfiguration {
                viewFactory.emptyCellView(date: date)
            }.margins(.all, 0)
        }
        let loadingCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewCell, Date
        > { [viewFactory] cell, _, date in
            cell.contentConfiguration = UIHostingConfiguration {
                viewFactory.loadingCellView(date: date)
            }.margins(.all, 0)
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [unowned self] cell, _, indexPath in
            let date = diffableDataStorage.section(
                in: diffableDataSource.snapshot(),
                for: indexPath.section
            ) ?? Date()
            cell.contentConfiguration = UIHostingConfiguration {
                viewFactory.dayHeaderView(date: date)
            }.margins(.all, 0)
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
                    using: event.isAllDay ? allDayEventCellRegistration : eventCellRegistration,
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
        autoUpdateTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                if let self {
                    await diffableDataSource.applySnapshotUsingReloadData(diffableDataSource.snapshot())
                }
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

    // MARK: - UICollectionViewDelegateFlowLayout

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

        let proposal = ProposedViewSize(width: bounds.width, height: nil)
        return switch viewModel.kind {
        case let .event(event):
            viewFactory.eventViewSizeThatFits(proposal: proposal, event: event)
        case .empty:
            viewFactory.emptyViewSizeThatFits(proposal: proposal, date: viewModel.date)
        case .loading:
            viewFactory.loadingViewSizeThatFits(proposal: proposal, date: viewModel.date)
        }
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let date = diffableDataStorage.section(
            in: diffableDataSource.snapshot(),
            for: section
        ) ?? Date()

        let proposal = ProposedViewSize(width: bounds.width, height: nil)
        return viewFactory.headerViewSizeThatFits(proposal: proposal, date: date)
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        viewFactory.insetsForSection()
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        viewFactory.interitemSpacing()
    }
}
