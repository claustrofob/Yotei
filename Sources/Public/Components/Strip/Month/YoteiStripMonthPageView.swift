//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripMonthPageView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private enum Constants {
        static var numberOfDaysPerWeek: Int {
            7
        }
    }

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
        let monthInterval = calendar.dateInterval(of: .month, for: date)!
        let numberOfWeeks = calendar.range(
            of: .weekOfMonth,
            in: .month,
            for: date
        )!.count
        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
        let daysSequence = YoteiDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek,
            calendar: calendar
        )

        TimelineView(.everyMinute) { context in
            VStack(spacing: viewFactory.weekInteritemVerticalSpacing()) {
                ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            let date = daysSequence[row * Constants.numberOfDaysPerWeek + col]
                            // monthInterval.end equals the start date of the next day
                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                            viewFactory.dayCellView(
                                date: date,
                                todayDate: context.date,
                                focusedDate: focusedDate,
                                isEnabled: isEnabled
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isEnabled {
                                    focusedDate = date
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
