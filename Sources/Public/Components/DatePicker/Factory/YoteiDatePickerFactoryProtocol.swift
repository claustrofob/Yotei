//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiDatePickerFactoryProtocol {
    associatedtype DayCellView: View
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool,
        calendar: Calendar
    ) -> DayCellView

    func dayCellViewHeight() -> CGFloat
    func weekInteritemVerticalSpacing() -> CGFloat

    associatedtype MonthSelectorButtonView: View
    func monthSelectorButtonView(
        date: Date,
        isExpanded: Bool,
        calendar: Calendar
    ) -> MonthSelectorButtonView

    associatedtype MonthBackButtonView: View
    func monthBackButtonView() -> MonthBackButtonView

    associatedtype MonthForwardButtonView: View
    func monthForwardButtonView() -> MonthForwardButtonView
}

public extension YoteiDatePickerFactoryProtocol {
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool,
        calendar: Calendar
    ) -> some View {
        YoteiDayCellDefaultView(
            date: date,
            todayDate: todayDate,
            focusedDate: focusedDate,
            isEnabled: isEnabled,
            calendar: calendar
        )
    }

    func dayCellViewHeight() -> CGFloat {
        40
    }

    func weekInteritemVerticalSpacing() -> CGFloat {
        8
    }

    func monthSelectorButtonView(
        date: Date,
        isExpanded: Bool,
        calendar: Calendar
    ) -> some View {
        YoteiMonthSelectorButtonDefaultView(
            date: date,
            isExpanded: isExpanded,
            calendar: calendar
        )
    }

    func monthBackButtonView() -> some View {
        YoteiMonthBackButtonDefaultView()
    }

    func monthForwardButtonView() -> some View {
        YoteiMonthForwardButtonDefaultView()
    }
}
