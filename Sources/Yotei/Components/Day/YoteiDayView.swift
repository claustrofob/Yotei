//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Internal
import SwiftUI

public struct YoteiDayView: View {
    @Binding var focusedDate: Date
    @Binding var data: YoteiEventsInterval
    @Binding var contentOffset: CGPoint?
    let delegate: YoteiDelegate?

    public var body: some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $focusedDate)
            CalendarTabView(
                selection: $focusedDate,
                content: { date in
                    VStack(spacing: 0) {
                        YoteiAllDayEventsTopView(
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
                        YoteiDayEventsView(
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
