//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiDayEventsViewFactoryProtocol<Data> {
    associatedtype Data: YoteiEventData

    associatedtype EventView: View
    func eventView(event: YoteiEvent<Data>) -> EventView

    associatedtype TimeSlotView: View
    func timeSlotView(date: Date) -> TimeSlotView

    associatedtype DaysDelimiterView: View
    func daysDelimiterView() -> DaysDelimiterView

    associatedtype CurrentTimeMarkerView: View
    func currentTimeMarkerView() -> CurrentTimeMarkerView

    associatedtype PlaceholderView: View
    func placeholderView() -> PlaceholderView

    func insetsForViewsLayout() -> EdgeInsets
    func insetsForScrollView() -> EdgeInsets
    func hourSlotHeight() -> CGFloat
}

public extension YoteiDayEventsViewFactoryProtocol {
    func eventView(event: YoteiEvent<Data>) -> some View {
        YoteiDayEventsEventDefaultView(event: event)
    }

    func timeSlotView(date: Date) -> some View {
        YoteiDayEventsTimeSlotDefaultView(date: date)
    }

    func daysDelimiterView() -> some View {
        YoteiDayEventsDaysDelimiterDefaultView()
    }

    func currentTimeMarkerView() -> some View {
        YoteiDayEventsCurrentTimeMarkerDefaultView()
    }

    func placeholderView() -> some View {
        YoteiDayEventsEventPlaceholderDefaultView()
    }

    func insetsForViewsLayout() -> EdgeInsets {
        EdgeInsets(top: 0, leading: 38, bottom: 0, trailing: 5)
    }

    func insetsForScrollView() -> EdgeInsets {
        EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 0)
    }

    func hourSlotHeight() -> CGFloat {
        60
    }
}
