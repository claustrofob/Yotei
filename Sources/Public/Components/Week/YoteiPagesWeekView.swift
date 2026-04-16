//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesWeekView<Content: View>: View {
    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    @ViewBuilder private let content: (Date) -> Content

    public init(
        focusedDate: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        _focusedDate = focusedDate
        self.content = content
    }

    public var body: some View {
        MainView(
            focusedDate: $focusedDate,
            initialPageDate: calendar.dateInterval(
                of: .weekOfMonth,
                for: focusedDate
            )!.start,
            content: content
        )
    }
}

private extension YoteiPagesWeekView {
    struct MainView: View {
        @Environment(\.calendar) private var calendar

        @Binding var focusedDate: Date
        @ViewBuilder let content: (Date) -> Content

        @State private var selectedPageDate: Date

        init(
            focusedDate: Binding<Date>,
            initialPageDate: Date,
            content: @escaping (Date) -> Content
        ) {
            _focusedDate = focusedDate
            selectedPageDate = initialPageDate
            self.content = content
        }

        var body: some View {
            DateTabView(
                selection: $selectedPageDate,
                content: { date in
                    content(date)
                        // Keep the navigation bar explicitly visible
                        // This view is hosted inside a UIPageViewController, and during some
                        // page transitions the navigation bar may be hidden unexpectedly
                        .toolbar(.visible, for: .navigationBar)
                },
                previousDate: { date in
                    calendar.date(byAdding: .weekOfMonth, value: -1, to: date)!
                },
                nextDate: { date in
                    calendar.date(byAdding: .weekOfMonth, value: 1, to: date)!
                }
            )
            .ignoresSafeArea()
            .onChange(of: selectedPageDate) { value in
                let calendarDateService = DateService(calendar: calendar)
                focusedDate = calendarDateService.weekFocusedDate(for: value, currentFocusedDate: focusedDate)
            }
            .onChange(of: focusedDate) { value in
                let startDate = calendar.dateInterval(
                    of: .weekOfMonth,
                    for: value
                )!.start

                guard startDate != selectedPageDate else {
                    return
                }
                selectedPageDate = startDate
            }
        }
    }
}
