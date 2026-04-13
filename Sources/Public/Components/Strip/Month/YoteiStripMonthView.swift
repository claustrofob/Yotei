//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripMonthView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
    }

    private let startDate: Date
    private let monthInterval: DateInterval
    private let numberOfWeeks: Int

    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        date: Date,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
        monthInterval = Calendar.current.dateInterval(of: .month, for: date)!
        numberOfWeeks = Calendar.current.range(
            of: .weekOfMonth,
            in: .month,
            for: date
        )!.count
        startDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
    }

    public var body: some View {
        let monthDays = YoteiDaysSequence(
            startDate: startDate,
            days: numberOfWeeks * Constants.numberOfDaysPerWeek
        )

        TimelineView(.everyMinute) { context in
            Grid(horizontalSpacing: 0, verticalSpacing: viewFactory.weekInteritemVerticalSpacing()) {
                ForEach(0 ..< numberOfWeeks, id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            let date = monthDays[row * Constants.numberOfDaysPerWeek + col]
                            // monthInterval.end equals the start date of the next day
                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                            Button(action: {
                                focusedDate = date
                            }, label: {
                                viewFactory.dayCellView(
                                    date: date,
                                    todayDate: context.date,
                                    focusedDate: focusedDate,
                                    isEnabled: isEnabled
                                )
                            })
                            .disabled(!isEnabled)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
