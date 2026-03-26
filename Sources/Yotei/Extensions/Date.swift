import Foundation

extension Date: @retroactive Identifiable {
    public var id: Date {
        self
    }
}

extension Date {
    func isEqual(
        to date: Date,
        toGranularity component: Calendar.Component,
        in calendar: Calendar = .current
    ) -> Bool {
        calendar.isDate(
            self,
            equalTo: date,
            toGranularity: component
        )
    }

    func isInSameDay(
        as date: Date,
        in _: Calendar = .current
    ) -> Bool {
        isEqual(
            to: date,
            toGranularity: .day
        )
    }

    func startOfDay(
        in calendar: Calendar = .current
    ) -> Date {
        calendar.startOfDay(for: self)
    }

    // Calendar.current.component(.weekOfMonth, from: date) depends on Calendar.current.minimumDaysInFirstWeek
    // and may return different values in different calendars and for different months.
    // E.g. for 01.08.2025 it will return 0 if minimumDaysInFirstWeek == 4, and 1 if minimumDaysInFirstWeek == 1
    func weekOfMonth(in calendar: Calendar) -> Int {
        let startOfMonth = calendar.dateInterval(of: .month, for: self)!.start
        let startOfFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: startOfMonth)!.start
        let days = calendar.dateComponents(
            [.day],
            from: startOfFirstWeek,
            to: self
        ).day!

        return days / 7
    }
}
