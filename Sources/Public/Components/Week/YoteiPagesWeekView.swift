//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesWeekView<Content: View>: View {
    @Binding private var focusedDate: Date
    @ViewBuilder private let content: (Date) -> Content

    private let calendarDateService = CalendarDateService()
    @State private var selectedPageDate: Date

    public init(
        focusedDate: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        _focusedDate = focusedDate
        self.content = content
        selectedPageDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: focusedDate.wrappedValue
        )!.start
    }

    public var body: some View {
        CalendarTabView(
            selection: $selectedPageDate,
            content: { date in
                content(date)
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
        .ignoresSafeArea()
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
        .onAppear {
            focusedDate = Calendar.current.startOfDay(for: focusedDate)
        }
    }
}
