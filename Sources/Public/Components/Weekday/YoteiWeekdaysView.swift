//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdaysView<ViewFactory: YoteiWeekdayViewFactoryProtocol>: View {
    @Environment(\.calendar) private var calendar

    private let weekStartDate: Date
    private var daysSequence: YoteiDaysSequence {
        YoteiDaysSequence(startDate: weekStartDate, days: 7, calendar: calendar)
    }

    private let viewFactory: ViewFactory

    public init(
        weekStartDate: Date,
        viewFactory: ViewFactory = YoteiWeekdayViewFactory()
    ) {
        self.weekStartDate = weekStartDate
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
