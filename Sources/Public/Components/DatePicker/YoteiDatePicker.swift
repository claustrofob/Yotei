//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDatePicker: View {
    private enum Constants {
        static var weekHeight: CGFloat { 40 }
        static var weekVPadding: CGFloat { 8 }
        static var maxNumberOfWeeks: CGFloat { 6 }
        static var maxMonthHeight: CGFloat {
            weekHeight * maxNumberOfWeeks + weekVPadding * (maxNumberOfWeeks - 1)
        }
    }

    private let monthYearFormatStyle: Date.FormatStyle
    @Binding private var selectedDate: Date
    private let minDate: Date?
    @State private var selectedPageDate: Date
    @State private var isMonthYearPickerExpanded = false
    private let calendar: Calendar

    public init(
        selectedDate: Binding<Date>,
        minDate: Date? = nil,
        calendar: Calendar = .current
    ) {
        self.calendar = calendar
        _selectedDate = selectedDate
        _selectedPageDate = State(initialValue: calendar.dateInterval(
            of: .month,
            for: selectedDate.wrappedValue
        )!.start)
        self.minDate = minDate.flatMap {
            calendar.startOfDay(for: $0)
        }
        monthYearFormatStyle = Date.FormatStyle(
            calendar: calendar, timeZone: calendar.timeZone
        ).month(.wide).year(.defaultDigits)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                monthYearButton()
                Spacer()
                if !isMonthYearPickerExpanded {
                    leftRightButtons()
                }
            }
            HStack {
                if isMonthYearPickerExpanded {
                    YoteiMonthYearPicker(date: $selectedDate, calendar: calendar)
                } else {
                    CalendarTabView(
                        selection: $selectedPageDate,
                        content: { date in
                            YoteiDatePickerMonth(
                                selectedDate: $selectedDate,
                                dateInMonth: date,
                                minDate: minDate,
                                calendar: calendar
                            )
                        },
                        previousDate: { date in
                            calendar.date(byAdding: .month, value: -1, to: date)!
                        },
                        nextDate: { date in
                            calendar.date(byAdding: .month, value: 1, to: date)!
                        }
                    )
                }
            }
            .frame(height: Constants.maxMonthHeight, alignment: .center)
        }
        .animation(.default, value: isMonthYearPickerExpanded)
        .onChange(of: selectedDate) { _ in
            generateSelectedPageDate()
        }
        .onFirstAppear {
            generateSelectedPageDate()
        }
    }
}

private extension YoteiDatePicker {
    func generateSelectedPageDate() {
        selectedPageDate = calendar.dateInterval(
            of: .month,
            for: selectedDate
        )!.start
    }

    func monthYearButton() -> some View {
        Button(action: {
            isMonthYearPickerExpanded.toggle()
        }) {
            HStack(spacing: 16) {
                Text(selectedPageDate.formatted(monthYearFormatStyle).capitalizedFirstLetter)
                    .font(.system(.body))
                Image(systemName: "chevron.right")
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(isMonthYearPickerExpanded ? 90 : 0))
            }
        }
        .frame(height: 44)
    }

    func leftRightButtons() -> some View {
        HStack(spacing: 4) {
            Button(action: {
                selectedPageDate = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: selectedPageDate
                )!
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.blue)
            }
            .frame(width: 32, height: 44)

            Button(action: {
                selectedPageDate = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: selectedPageDate
                )!
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.blue)
            }
            .frame(width: 32, height: 44)
        }
    }
}
