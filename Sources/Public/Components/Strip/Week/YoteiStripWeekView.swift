//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripWeekView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private let weekInterval: DateInterval
    private let calendar: Calendar
    private let daysSequence: YoteiDaysSequence

    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        date: Date,
        calendar: Calendar,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
        self.calendar = calendar
        weekInterval = calendar.dateInterval(of: .weekOfMonth, for: date)!

        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: date
        )!.start
        daysSequence = YoteiDaysSequence(startDate: startDate, days: 7, calendar: calendar)
    }

    public var body: some View {
        TimelineView(.everyMinute) { context in
            Grid(horizontalSpacing: 0, verticalSpacing: viewFactory.weekInteritemVerticalSpacing()) {
                GridRow {
                    ForEach(daysSequence, id: \.self) { date in
                        Button(action: {
                            focusedDate = date
                        }, label: {
                            viewFactory.dayCellView(
                                date: date,
                                todayDate: context.date,
                                focusedDate: focusedDate,
                                isEnabled: true,
                                calendar: calendar
                            )
                        })
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
