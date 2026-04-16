//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripWeekView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    private let date: Date
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        date: Date,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.date = date
        self.viewFactory = viewFactory
    }

    public var body: some View {
        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: date
        )!.start

        MainView(
            focusedDate: $focusedDate,
            daysSequence: YoteiDaysSequence(startDate: startDate, days: 7, calendar: calendar),
            viewFactory: viewFactory
        )
    }
}

private extension YoteiStripWeekView {
    struct MainView: View {
        @Environment(\.calendar) private var calendar

        @Binding var focusedDate: Date
        let daysSequence: YoteiDaysSequence
        let viewFactory: ViewFactory

        var body: some View {
            TimelineView(.everyMinute) { context in
                Grid(horizontalSpacing: 0, verticalSpacing: viewFactory.weekInteritemVerticalSpacing()) {
                    GridRow {
                        ForEach(daysSequence, id: \.self) { date in
                            Button(action: {
                                focusedDate = date
                            }, label: {
                                viewFactory.dayCellView(
                                    date: date,
                                    todayDate: context.date,
                                    focusedDate: focusedDate,
                                    isEnabled: true,
                                    calendar: calendar
                                )
                            })
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
