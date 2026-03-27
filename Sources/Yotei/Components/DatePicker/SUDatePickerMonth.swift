import Internal
import SwiftUI

struct SUDatePickerMonth: View {
    enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
    }

    @Binding private var selectedDate: Date
    private let minDate: Date?
    private let days: CalendarDaysSequence
    private let monthInterval: DateInterval
    private let numberOfWeeks: Int
    private let calendar: Calendar

    init(
        selectedDate: Binding<Date>,
        dateInMonth: Date,
        minDate: Date? = nil,
        calendar: Calendar
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
        days = CalendarDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek,
            calendar: calendar
        )
        self.minDate = minDate
    }

    var body: some View {
        let todayDate = Date.now
        Grid(horizontalSpacing: 10, verticalSpacing: 8) {
            ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                        let date = days[row * Constants.numberOfDaysPerWeek + col]
                        if monthInterval.contains(date) && monthInterval.end != date {
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
                                CalendarDayCellView(
                                    date: date,
                                    todayDate: todayDate,
                                    focusedDate: selectedDate,
                                    isEnabled: minDate.flatMap { $0 <= date } ?? true,
                                    calendar: calendar
                                )
                            })
                        } else {
                            Color.clear.frame(height: 1)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
