import SwiftUI

struct CalendarStripMonthModuleView: View {
    private enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
    }

    private let startDate: Date
    private let monthInterval: DateInterval
    private let numberOfWeeks: Int

    @Binding var focusedDate: Date

    init(focusedDate: Binding<Date>, date: Date) {
        _focusedDate = focusedDate
        monthInterval = Calendar.current.dateInterval(of: .month, for: date)!
        numberOfWeeks = Calendar.current.range(
            of: .weekOfMonth,
            in: .month,
            for: date
        )!.count
        startDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
    }

    var body: some View {
        let monthDays = CalendarDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek
        )

        TimelineView(.everyMinute) { context in
            Grid(horizontalSpacing: 10, verticalSpacing: 8) {
                ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            let date = monthDays[row * Constants.numberOfDaysPerWeek + col]
                            // monthInterval.end equals the start date of the next day
                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                            Button(action: {
                                focusedDate = date
                            }, label: {
                                CalendarDayCellView(
                                    date: date,
                                    todayDate: context.date,
                                    focusedDate: focusedDate,
                                    isEnabled: isEnabled
                                )
                            })
                            .disabled(!isEnabled)
                        }
                    }
                }
            }
        }
    }
}
