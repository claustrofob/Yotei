//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDatePicker<ViewFactory: YoteiDatePickerFactoryProtocol>: View {
    private enum Constants {
        static var maxNumberOfWeeks: CGFloat { 6 }
    }

    private let monthYearFormatStyle: Date.FormatStyle
    @Binding private var selectedDate: Date
    private let minDate: Date?
    private let viewFactory: ViewFactory

    @State private var selectedPageDate: Date
    @State private var isMonthYearPickerExpanded = false
    private let calendar: Calendar

    private var maxMonthHeight: CGFloat {
        viewFactory.dayCellViewHeight() * Constants.maxNumberOfWeeks
            + viewFactory.weekInteritemVerticalSpacing() * (Constants.maxNumberOfWeeks - 1)
    }

    public init(
        selectedDate: Binding<Date>,
        minDate: Date? = nil,
        calendar: Calendar = .current,
        viewFactory: ViewFactory = YoteiDatePickerFactory()
    ) {
        self.calendar = calendar
        _selectedDate = selectedDate
        _selectedPageDate = State(initialValue: calendar.dateInterval(
            of: .month,
            for: selectedDate.wrappedValue
        )!.start)
        self.viewFactory = viewFactory
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
                    backForwardButtons()
                }
            }
            .foregroundStyle(.primary)
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
            .frame(height: maxMonthHeight, alignment: .center)
        }
        .animation(.default, value: isMonthYearPickerExpanded)
        .onChange(of: selectedDate) { _ in
            generateSelectedPageDate()
        }
        .onAppear {
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
                    .rotationEffect(.degrees(isMonthYearPickerExpanded ? 90 : 0))
            }
        }
        .frame(height: 44)
    }

    func backForwardButtons() -> some View {
        HStack(spacing: 4) {
            Button(action: {
                selectedPageDate = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: selectedPageDate
                )!
            }) {
                Image(systemName: "chevron.left")
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
            }
            .frame(width: 32, height: 44)
        }
    }
}
