import SwiftUI
import Swinject

struct CalendarStripWeekModuleView: View {
    private let weekInterval: DateInterval
    private let startDate: Date

    @Binding var focusedDate: Date

    init(focusedDate: Binding<Date>, date: Date) {
        _focusedDate = focusedDate
        weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: date)!
        startDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: date
        )!.start
    }

    var body: some View {
        let weekDays = CalendarDaysSequence(startDate: startDate, days: 7)
        TimelineView(.everyMinute) { context in
            Grid(horizontalSpacing: 10, verticalSpacing: 8) {
                GridRow {
                    ForEach(weekDays, id: \.self) { date in
                        Button(action: {
                            focusedDate = date
                        }, label: {
                            CalendarDayCellView(
                                date: date,
                                todayDate: context.date,
                                focusedDate: focusedDate,
                                eventCounts: 0,
                                isEnabled: true
                            )
                        })
                    }
                }
            }
        }
    }
}
