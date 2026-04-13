//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdaysView<ViewFactory: YoteiWeekdayViewFactoryProtocol>: View {
    private let weekStartDate: Date
    private let daysSequence: YoteiDaysSequence
    private let calendar: Calendar
    private let viewFactory: ViewFactory

    public init(
        weekStartDate: Date,
        calendar: Calendar = .current,
        viewFactory: ViewFactory = YoteiWeekdayViewFactory()
    ) {
        self.weekStartDate = weekStartDate
        self.calendar = calendar
        daysSequence = YoteiDaysSequence(startDate: weekStartDate, days: 7, calendar: calendar)
        self.viewFactory = viewFactory
    }

    public var body: some View {
        TimelineView(.everyMinute) { context in
            HStack(spacing: 0) {
                ForEach(daysSequence, id: \.self) { date in
                    viewFactory.dayCellView(date: date, todayDate: context.date, calendar: calendar)
                }
            }
        }
    }
}
