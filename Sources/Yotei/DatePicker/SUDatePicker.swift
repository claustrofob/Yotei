import Media
import SwiftUI

struct SUDatePicker: View {
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

    init(
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

    var body: some View {
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
                    SUMonthYearPicker(date: $selectedDate, calendar: calendar)
                } else {
                    CalendarTabView(
                        selection: $selectedPageDate,
                        content: { date in
                            SUDatePickerMonth(
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

    private func generateSelectedPageDate() {
        selectedPageDate = calendar.dateInterval(
            of: .month,
            for: selectedDate
        )!.start
    }

    private func monthYearButton() -> some View {
        Button(action: {
            isMonthYearPickerExpanded.toggle()
        }) {
            HStack(spacing: 16) {
                Text(selectedPageDate.formatted(monthYearFormatStyle).capitalizedFirstLetter)
                    .font(.system(.body))
                Media.Calendar.calendarAddEventRight.swiftUIImage
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(isMonthYearPickerExpanded ? 90 : 0))
            }
        }
        .frame(height: 44)
    }

    private func leftRightButtons() -> some View {
        HStack(spacing: 4) {
            Button(action: {
                selectedPageDate = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: selectedPageDate
                )!
            }) {
                Media.Calendar.calendarPickerRightArrow.swiftUIImage
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(180))
            }
            .frame(width: 32, height: 44)

            Button(action: {
                selectedPageDate = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: selectedPageDate
                )!
            }) {
                Media.Calendar.calendarPickerRightArrow.swiftUIImage
                    .foregroundStyle(.blue)
            }
            .frame(width: 32, height: 44)
        }
    }
}
