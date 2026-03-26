import Foundation

public struct CalendarEventsInterval: Equatable {
    // full interval: [a few prev days + monthInterval + a few next days]
    public let dateInterval: DateInterval?
    public let dateLoadingInterval: DateInterval?
    // active month interval
    public let monthInterval: DateInterval?
    public let events: [Date: [CalendarEvent]]

    public init(
        dateInterval: DateInterval? = nil,
        dateLoadingInterval: DateInterval? = nil,
        monthInterval: DateInterval? = nil,
        events: [Date: [CalendarEvent]] = [:]
    ) {
        self.dateInterval = dateInterval
        self.dateLoadingInterval = dateLoadingInterval
        self.monthInterval = monthInterval
        self.events = events
    }
}
