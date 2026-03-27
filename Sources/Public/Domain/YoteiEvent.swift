//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public struct YoteiEvent: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let start: Date
    public let end: Date
    public let isAllDay: Bool

    public init(
        id: String,
        title: String,
        start: Date,
        end: Date,
        isAllDay: Bool
    ) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
    }
}

// All day event date rules:
// - It must not depend on timezone. `18.01.2026 00:00:00 UTC` must be displayed on `18.01.2026` in every timezone
// - Google Calendar always returns all day event date with `00:00:00 UTC`
// - endDate can be equal to startDate or be greater. If it is greater we must not count the last day.
//   E.g. `18.01.2026 00:00:00 UTC` - `19.01.2026 00:00:00 UTC` - this interval represents just one day `18.01.2026`
//        `18.01.2026 00:00:00 UTC` - `20.01.2026 00:00:00 UTC` - this interval represents 2 days `18.01.2026` and `19.01.2026`
extension YoteiEvent {
    // preserve day when converting to other timezone
    private func startOfDay(
        from date: Date,
        inputCalendar: Calendar,
        outputCalendar: Calendar
    ) -> Date {
        let components = inputCalendar.dateComponents([.year, .month, .day], from: date)
        return outputCalendar.date(from: components) ?? date
    }

    private func dayPreservedInterval(in calendar: Calendar = .current) -> DateInterval {
        let utcCalendar = Calendar(timeZone: .gmt)

        // transform UTC date into current timezone with preserved day, month and year
        let startDate = startOfDay(
            from: start,
            inputCalendar: utcCalendar,
            outputCalendar: calendar
        )
        var endDate = startOfDay(
            from: end,
            inputCalendar: utcCalendar,
            outputCalendar: calendar
        )
        if !calendar.isDate(startDate, inSameDayAs: endDate), endDate > startDate {
            // date interval for all day event usually looks like this:
            // `18.01.2026 00:00:00 UTC` - `19.01.2026 00:00:00 UTC` - this interval represents just one day `18.01.2026`
            // to correctly display this on UI we need to substruct one day from endDate
            endDate = calendar.date(
                byAdding: .day,
                value: -1,
                to: endDate
            )!
        }

        return DateInterval(start: startDate, end: endDate)
    }

    public func displayableDateInterval(in calendar: Calendar = .current) -> DateInterval {
        isAllDay ? dayPreservedInterval(in: calendar) : dateInterval
    }

    public var dateInterval: DateInterval {
        DateInterval(start: start, end: end)
    }
}

// MARK: Sortable

public extension YoteiEvent {
    var isAllDaySortable: Int { isAllDay ? 0 : 1 }
    var durationSortable: Double { end.timeIntervalSince1970 - start.timeIntervalSince1970 }
}
