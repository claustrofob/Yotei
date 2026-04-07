//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripWeekView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private let weekInterval: DateInterval
    private let startDate: Date

    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        date: Date,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
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
