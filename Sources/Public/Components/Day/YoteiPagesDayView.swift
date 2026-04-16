//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesDayView<Content: View>: View {
    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    @ViewBuilder private let content: (Date) -> Content

    public init(
        focusedDate: Binding<Date>,
        calendar _: Calendar,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        _focusedDate = focusedDate
        self.content = content
    }

    public var body: some View {
        DateTabView(
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
