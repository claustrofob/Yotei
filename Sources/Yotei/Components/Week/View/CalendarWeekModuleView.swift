import ReactiveSwift
import SwiftUI
import Swinject
import Utilities

struct CalendarWeekModuleView: View {
    private enum Constants {
        static var weekTitlesViewInsets: EdgeInsets {
            EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0)
        }
    }

    @Binding var focusedDate: Date
    @Binding var data: CalendarEventsInterval
    let delegate: CalendarDelegate?

    private let calendarDateService = CalendarDateService()
    @State private var selectedPageDate: Date

    init(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) {
        _focusedDate = focusedDate
        _data = data
        self.delegate = delegate
        selectedPageDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: focusedDate.wrappedValue
        )!.start
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarWeekTitlesView(spacing: 0)
                .padding(Constants.weekTitlesViewInsets)

            CalendarTabView(
                selection: $selectedPageDate,
                content: { date in
                    VStack(spacing: 0) {
                        weekDaysView(startDate: date)
                            .padding(Constants.weekTitlesViewInsets)
                            .padding(.bottom, 4)
                        CalendarAllDayEventsTopModuleBuilder(startDate: date, numberOfDays: 7).view(
                            data: $data,
                            delegate: delegate
                        )
                        .padding(Constants.weekTitlesViewInsets)
                        CalendarHorizontalSeparator()
                        CalendarDayEventsModuleBuilder(startDate: date, numberOfDays: 7).view(
                            data: $data,
                            delegate: delegate
                        )
                    }
                    // Keep the navigation bar explicitly visible
                    // This view is hosted inside a UIPageViewController, and during some
                    // page transitions the navigation bar may be hidden unexpectedly
                    .toolbar(.visible, for: .navigationBar)
                },
                previousDate: { date in
                    Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
                },
                nextDate: { date in
                    Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
                }
            )
        }
        .onChange(of: selectedPageDate) { value in
            focusedDate = calendarDateService.weekFocusedDate(for: value, currentFocusedDate: focusedDate)
        }
        .onChange(of: focusedDate) { value in
            let startDate = Calendar.current.dateInterval(
                of: .weekOfMonth,
                for: value
            )!.start

            guard startDate != selectedPageDate else {
                return
            }
            selectedPageDate = startDate
        }
    }

    @ViewBuilder
    private func weekDaysView(startDate: Date) -> some View {
        TimelineView(.everyMinute) { context in
            HStack(spacing: 0) {
                ForEach(CalendarDaysSequence(startDate: startDate, days: 7), id: \.self) { date in
                    CalendarDayCellView(date: date, todayDate: context.date)
                }
            }
        }
    }
}
