//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesDayView<Content: View>: View {
    @Binding private var focusedDate: Date
    private let calendar: Calendar
    @ViewBuilder private let content: (Date) -> Content

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
        self.content = content
    }

    public var body: some View {
        CalendarTabView(
            selection: $focusedDate,
            content: { date in
                content(date)
                    // Keep the navigation bar explicitly visible
                    // This view is hosted inside a UIPageViewController, and during some
                    // page transitions the navigation bar may be hidden unexpectedly
                    .toolbar(.visible, for: .navigationBar)
            },
            previousDate: { date in
                calendar.date(byAdding: .day, value: -1, to: date)!
            },
            nextDate: { date in
                calendar.date(byAdding: .day, value: 1, to: date)!
            }
        )
        .ignoresSafeArea()
    }
}
