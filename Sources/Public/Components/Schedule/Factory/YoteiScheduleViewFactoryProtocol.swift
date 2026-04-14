//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiScheduleViewFactoryProtocol {
    associatedtype EventCellView: View
    func eventCellView(
        date: Date,
        event: YoteiEvent,
        calendar: Calendar
    ) -> EventCellView

    associatedtype AllDayEventCellView: View
    func allDayEventCellView(
        date: Date,
        event: YoteiEvent,
        calendar: Calendar
    ) -> AllDayEventCellView

    associatedtype EmptyCellView: View
    func emptyCellView(date: Date) -> EmptyCellView

    associatedtype LoadingCellView: View
    func loadingCellView(date: Date) -> LoadingCellView

    associatedtype DayHeaderView: View
    func dayHeaderView(date: Date, calendar: Calendar) -> DayHeaderView

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize
    func emptyViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func loadingViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func headerViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize

    func insetsForSection() -> UIEdgeInsets
    func interitemSpacing() -> CGFloat
}

public extension YoteiScheduleViewFactoryProtocol {
    func eventCellView(
        date: Date,
        event: YoteiEvent,
        calendar: Calendar
    ) -> some View {
        YoteiScheduleEventCellDefaultView(
            cellDate: date,
            event: event,
            calendar: calendar
        )
    }

    func allDayEventCellView(
        date: Date,
        event: YoteiEvent,
        calendar: Calendar
    ) -> some View {
        YoteiScheduleAllDayEventCellDefaultView(
            cellDate: date,
            event: event,
            calendar: calendar
        )
    }

    func emptyCellView(date _: Date) -> some View {
        YoteiScheduleEmptyCellDefaultView()
    }

    func loadingCellView(date _: Date) -> some View {
        YoteiScheduleLoadingCellDefaultView()
    }

    func dayHeaderView(date: Date, calendar: Calendar) -> some View {
        YoteiScheduleSectionHeaderDefaultView(
            date: date,
            sectionInsets: insetsForSection(),
            calendar: calendar
        )
    }

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let sectionInsets = insetsForSection()
        let width = size.width - sectionInsets.left - sectionInsets.right
        return CGSize(width: width, height: event.isAllDay ? 16 : 52)
    }

    func emptyViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let sectionInsets = insetsForSection()
        let width = size.width - sectionInsets.left - sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func loadingViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let sectionInsets = insetsForSection()
        let width = size.width - sectionInsets.left - sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func headerViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        return CGSize(width: size.width, height: 28)
    }

    func insetsForSection() -> UIEdgeInsets {
        .init(top: 6, left: 16, bottom: 16, right: 16)
    }

    func interitemSpacing() -> CGFloat {
        8
    }
}
