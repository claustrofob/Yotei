import SwiftUI

struct CalendarDayView: View {
    @Binding var focusedDate: Date
    @Binding var data: CalendarEventsInterval
    @Binding var contentOffset: CGPoint?
    let delegate: CalendarDelegate?

    var body: some View {
        VStack(spacing: 0) {
            CalendarStripContainerView(focusedDate: $focusedDate)
            CalendarTabView(
                selection: $focusedDate,
                content: { date in
                    VStack(spacing: 0) {
                        CalendarAllDayEventsTopView(
                            startDate: date,
                            numberOfDays: 1,
                            data: $data,
                            delegate: delegate
                        )
                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 6))
                        .background {
                            Text("All day")
                                .font(.system(.caption))
                                .padding(.horizontal, 4)
                                .frame(width: 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .clipped()
                        CalendarHorizontalSeparator()
                        CalendarDayEventsView(
                            startDate: date,
                            numberOfDays: 1,
                            data: $data,
                            contentOffset: $contentOffset,
                            delegate: delegate
                        )
                    }
                    // Keep the navigation bar explicitly visible
                    // This view is hosted inside a UIPageViewController, and during some
                    // page transitions the navigation bar may be hidden unexpectedly
                    .toolbar(.visible, for: .navigationBar)
                },
                previousDate: { date in
                    Calendar.current.date(byAdding: .day, value: -1, to: date)!
                },
                nextDate: { date in
                    Calendar.current.date(byAdding: .day, value: 1, to: date)!
                }
            )
        }
    }
}
