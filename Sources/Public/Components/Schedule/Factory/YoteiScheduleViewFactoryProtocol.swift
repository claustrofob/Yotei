//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiScheduleViewFactoryProtocol {
    associatedtype EventCellView: View
    func eventCellView(date: Date, event: YoteiEvent) -> EventCellView

    associatedtype EmptyCellView: View
    func emptyCellView(date: Date) -> EmptyCellView

    associatedtype LoadingCellView: View
    func loadingCellView(date: Date) -> LoadingCellView

    associatedtype DayHeaderView: View
    func dayHeaderView(date: Date) -> DayHeaderView

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize
    func emptyViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func loadingViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func headerViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize

    func insetsForHeader() -> UIEdgeInsets
    func headerLineSpacing() -> CGFloat
    func interitemSpacing() -> CGFloat
}

public extension YoteiScheduleViewFactoryProtocol {
    func eventCellView(date: Date, event: YoteiEvent) -> some View {
        YoteiScheduleEventCellDefaultView(cellDate: date, event: event)
    }

    func emptyCellView(date _: Date) -> some View {
        YoteiScheduleEmptyCellDefaultView()
    }

    func loadingCellView(date _: Date) -> some View {
        YoteiScheduleLoadingCellDefaultView()
    }

    func dayHeaderView(date: Date) -> some View {
        YoteiScheduleSectionHeaderDefaultView(date: date)
    }

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - YoteiScheduleViewConstants.sectionInsets.left - YoteiScheduleViewConstants.sectionInsets.right
        return CGSize(width: width, height: event.isAllDay ? 16 : 52)
    }

    func emptyViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - YoteiScheduleViewConstants.sectionInsets.left - YoteiScheduleViewConstants.sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func loadingViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - YoteiScheduleViewConstants.sectionInsets.left - YoteiScheduleViewConstants.sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func headerViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        return CGSize(width: size.width, height: 28)
    }

    func insetsForHeader() -> UIEdgeInsets {
        YoteiScheduleViewConstants.sectionInsets
    }

    func headerLineSpacing() -> CGFloat {
        8
    }

    func interitemSpacing() -> CGFloat {
        8
    }
}
