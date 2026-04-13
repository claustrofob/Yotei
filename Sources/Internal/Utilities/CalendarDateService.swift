//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct CalendarDateService {
    private let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }
}

extension CalendarDateService {
    func monthFocusedDate(for dateInMonth: Date, currentFocusedDate: Date) -> Date {
        let monthInterval = calendar.dateInterval(of: .month, for: currentFocusedDate)!
        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start

        let index = calendar.dateComponents(
            [.day],
            from: startDate,
            to: currentFocusedDate
        ).day!

        let nextMonthInterval = calendar.dateInterval(of: .month, for: dateInMonth)!
        let nextMonthStart = nextMonthInterval.start
        let nextMonthEnd = calendar.date(
            byAdding: .day,
            value: -1,
            to: nextMonthInterval.end
        )!
        let nextStartDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: nextMonthStart
        )!.start

        let nextFocusedDate = calendar.date(
            byAdding: .day,
            value: index,
            to: nextStartDate
        )!
        return max(min(nextFocusedDate, nextMonthEnd), nextMonthStart)
    }

    func weekFocusedDate(for dateInWeek: Date, currentFocusedDate: Date) -> Date {
        let weekday = calendar.ordinality(
            of: .day,
            in: .weekOfMonth,
            for: currentFocusedDate
        )! - 1
        let nextWeekStart = calendar.dateInterval(of: .weekOfMonth, for: dateInWeek)!.start
        return calendar.date(
            byAdding: .day,
            value: weekday,
            to: nextWeekStart
        )!
    }
}
