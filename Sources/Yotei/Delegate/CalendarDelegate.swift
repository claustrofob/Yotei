import Foundation

protocol CalendarDelegate: AnyObject {
    func calendarDidSelectEvent(with id: CalendarEvent.ID)
    func calendarDidSelectAllDay(date: Date)
}
