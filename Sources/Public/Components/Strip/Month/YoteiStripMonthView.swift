//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripMonthView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
    }

    private let monthInterval: DateInterval
    private let numberOfWeeks: Int
    private let daysSequence: YoteiDaysSequence

    @Binding private var focusedDate: Date
    private let calendar: Calendar
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        date: Date,
        calendar: Calendar,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.calendar = calendar
        self.viewFactory = viewFactory
        monthInterval = calendar.dateInterval(of: .month, for: date)!
        numberOfWeeks = calendar.range(
            of: .weekOfMonth,
            in: .month,
            for: date
        )!.count

        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
        daysSequence = YoteiDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek,
            calendar: calendar
        )
    }

    public var body: some View {
        TimelineView(.everyMinute) { context in
            Grid(horizontalSpacing: 0, verticalSpacing: viewFactory.weekInteritemVerticalSpacing()) {
                ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            let date = daysSequence[row * Constants.numberOfDaysPerWeek + col]
                            // monthInterval.end equals the start date of the next day
                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                            Button(action: {
                                focusedDate = date
                            }, label: {
                                viewFactory.dayCellView(
                                    date: date,
                                    todayDate: context.date,
                                    focusedDate: focusedDate,
                                    isEnabled: isEnabled,
                                    calendar: calendar
                                )
                            })
                            .disabled(!isEnabled)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
