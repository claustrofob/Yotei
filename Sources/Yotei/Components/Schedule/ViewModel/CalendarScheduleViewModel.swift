import Foundation

struct CalendarScheduleViewModel: Identifiable, Equatable {
    enum Kind: Equatable {
        case event(CalendarEvent)
        case empty
        case loading
    }

    let date: Date
    let kind: Kind

    var id: String {
        switch kind {
        case let .event(item):
            "event_\(date.timeIntervalSince1970)_\(item.id)"
        case .empty:
            "empty_\(date.timeIntervalSince1970)"
        case .loading:
            "loading_\(date.timeIntervalSince1970)"
        }
    }
}
