//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesWeekView<Content: View>: View {
    @Binding private var focusedDate: Date
    private let calendar: Calendar
    @ViewBuilder private let content: (Date) -> Content

    private let calendarDateService: DateService
    @State private var selectedPageDate: Date

    public init(
        focusedDate: Binding<Date>,
        calendar: Calendar,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        _focusedDate = Binding(get: {
            calendar.startOfDay(for: focusedDate.wrappedValue)
        }, set: {
            focusedDate.wrappedValue = $0
        })
        self.calendar = calendar
        calendarDateService = DateService(calendar: calendar)
        self.content = content
        selectedPageDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: focusedDate.wrappedValue
        )!.start
    }

    public var body: some View {
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
