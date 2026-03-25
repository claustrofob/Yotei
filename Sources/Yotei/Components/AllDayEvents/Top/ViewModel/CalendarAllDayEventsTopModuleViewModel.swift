import Foundation

enum CalendarAllDayEventsTopModuleViewModel: Equatable, Identifiable {
    var id: String {
        switch self {
        case .event(event: let event, cols: _):
            "event_\(event.serverID)"
        case let .empty(index):
            "empty_\(index)"
        }
    }

    case event(event: CalendarEvent, cols: Int)
    case empty(index: Int)
}
