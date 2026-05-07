//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiPagesMonthViewFactoryProtocol<Data> {
    associatedtype Data: YoteiEventData

    associatedtype DayCellView: View
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> DayCellView

    associatedtype EventView: View
    func eventView(event: YoteiEvent<Data>) -> EventView

    associatedtype MoreEventsView: View
    func moreEventsView(count: Int) -> MoreEventsView

    associatedtype VerticalDelimiterView: View
    func verticalDelimiterView() -> VerticalDelimiterView

    associatedtype HorizontalDelimiterView: View
    func horizontalDelimiterView() -> HorizontalDelimiterView

    func eventViewHeight() -> CGFloat
    func interitemVerticalSpacing() -> CGFloat
    func interitemHorizontalSpacing() -> CGFloat
    func minNumberOfVisibleRows() -> Int
}

public extension YoteiPagesMonthViewFactoryProtocol {
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> some View {
        YoteiPagesMonthDayCellDefaultView(
            date: date,
            todayDate: todayDate,
            focusedDate: focusedDate,
            isEnabled: isEnabled
        )
    }

    func eventView(event: YoteiEvent<Data>) -> some View {
        YoteiPagesMonthEventDefaultView(event: event)
    }

    func moreEventsView(count: Int) -> some View {
        YoteiPagesMonthMoreEventsDefaultView(moreEventsCount: count)
    }

    func verticalDelimiterView() -> some View {
        YoteiPagesMonthVerticalDelimiterDefaultView()
    }

    func eventViewHeight() -> CGFloat {
        14
    }

    func horizontalDelimiterView() -> some View {
        YoteiPagesMonthHorizontalDelimiterDefaultView()
    }

    func interitemVerticalSpacing() -> CGFloat {
        2
    }

    func interitemHorizontalSpacing() -> CGFloat {
        0
    }

    func minNumberOfVisibleRows() -> Int {
        3
    }
}
