import SwiftUI

struct CalendarDayModuleView: View {
    @Binding var focusedDate: Date

    var body: some View {
        VStack(spacing: 0) {
            CalendarStripContainerModuleRoute().view(container)
            CalendarTabView(
                selection: $focusedDate,
                content: { date in
                    VStack(spacing: 0) {
                        CalendarAllDayEventsTopModuleRoute(startDate: date, numberOfDays: 1).view(container)
                            .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 6))
                            .background {
                                Text(String.localized_calendar_event_all_day)
                                    .themeFont(.subcaption)
                                    .themeTextColor(.base80)
                                    .padding(.horizontal, 4)
                                    .frame(width: 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .clipped()
                        CalendarHorizontalSeparator()
                        CalendarDayEventsModuleRoute(startDate: date, numberOfDays: 1).view(container)
                    }
                    .themeBackground(.base)
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
        .themeBackground(.base)
    }
}
