//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripWeekView: View {
    private let weekInterval: DateInterval
    private let startDate: Date

    @Binding private var focusedDate: Date

    public init(focusedDate: Binding<Date>, date: Date) {
        _focusedDate = focusedDate
        weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: date)!
        startDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: date
        )!.start
    }

    public var body: some View {
        let weekDays = YoteiDaysSequence(startDate: startDate, days: 7)
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
                                isEnabled: true
                            )
                        })
                    }
                }
            }
        }
    }
}
