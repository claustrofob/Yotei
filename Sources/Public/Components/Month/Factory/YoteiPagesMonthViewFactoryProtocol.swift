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

    associatedtype VerticalDelimiterView: View
    func verticalDelimiterView() -> VerticalDelimiterView

    associatedtype HorizontalDelimiterView: View
    func horizontalDelimiterView() -> HorizontalDelimiterView
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

    func verticalDelimiterView() -> some View {
        YoteiPagesMonthVerticalDelimiterDefaultView()
    }

    func horizontalDelimiterView() -> some View {
        YoteiPagesMonthHorizontalDelimiterDefaultView()
    }
}
