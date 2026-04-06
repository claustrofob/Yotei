//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public struct YoteiDaysSequence: RandomAccessCollection {
    private let calendar: Calendar
    private let startDate: Date

    public var startIndex: Int { 0 }
    // `count` = `endIndex - 1`
    public let endIndex: Int

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> Date {
        calendar.date(
            byAdding: .day,
            value: position,
            to: startDate
        )!
    }

    public init(interval: DateInterval, calendar: Calendar = .current) {
        self.calendar = calendar
        startDate = calendar.startOfDay(for: interval.start)
        endIndex = DateInterval(
            start: startDate,
            end: calendar.startOfDay(for: interval.end)
        ).durationInDays + 1
    }

    public init(
        startDate: Date,
        days: Int,
        calendar: Calendar = .current
    ) {
        self.calendar = calendar
        self.startDate = calendar.startOfDay(for: startDate)
        endIndex = days
    }
}
