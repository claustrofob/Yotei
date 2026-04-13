//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDatePickerMonth<ViewFactory: YoteiDatePickerFactoryProtocol>: View {
    enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
    }

    @Binding private var selectedDate: Date
    private let minDate: Date?
    private let maxDate: Date?
    private let days: YoteiDaysSequence
    private let monthInterval: DateInterval
    private let numberOfWeeks: Int
    private let calendar: Calendar
    private let viewFactory: ViewFactory

    public init(
        selectedDate: Binding<Date>,
        dateInMonth: Date,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        calendar: Calendar,
        viewFactory: ViewFactory = YoteiDatePickerFactory()
    ) {
        _selectedDate = selectedDate
        self.calendar = calendar

        monthInterval = calendar.dateInterval(of: .month, for: dateInMonth)!
        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
        numberOfWeeks = calendar.range(
            of: .weekOfMonth,
            in: .month,
            for: dateInMonth
        )!.count
        days = YoteiDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek,
            calendar: calendar
        )
        self.minDate = minDate.flatMap {
            calendar.startOfDay(for: $0)
        }
        self.maxDate = maxDate.flatMap {
            calendar.startOfDay(for: $0)
        }
        self.viewFactory = viewFactory
    }

    public var body: some View {
        let todayDate = Date.now
        Grid(horizontalSpacing: 0, verticalSpacing: viewFactory.weekInteritemVerticalSpacing()) {
            ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                        let date = days[row * Constants.numberOfDaysPerWeek + col]
                        if monthInterval.contains(date), monthInterval.end != date {
                            let isEnabled = (minDate.flatMap { $0 <= date } ?? true)
                                && (maxDate.flatMap { $0 >= date } ?? true)
                            Button(action: {
                                let selectedDateComponents = calendar.dateComponents(
                                    [.hour, .minute, .second],
                                    from: selectedDate
                                )
                                let newDate = calendar.date(
                                    bySettingHour: selectedDateComponents.hour!,
                                    minute: selectedDateComponents.minute!,
                                    second: selectedDateComponents.second!,
                                    of: date
                                )!
                                selectedDate = newDate
                            }, label: {
                                viewFactory.dayCellView(
                                    date: date,
                                    todayDate: todayDate,
                                    focusedDate: selectedDate,
                                    isEnabled: isEnabled
                                )
                            })
                            .disabled(!isEnabled)
                        } else {
                            Color.clear.frame(height: 1)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
