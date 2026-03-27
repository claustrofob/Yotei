import Foundation

public protocol YoteiDelegate: AnyObject {
    func calendarDidSelectEvent(with id: YoteiEvent.ID)
    func calendarDidSelectAllDay(date: Date)
    func calendarDidSelect(dateInterval: DateInterval)
}
