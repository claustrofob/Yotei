import Foundation
import UIKit

final class CalendarDayEventsModulePresenter: ObservableObject {
    let startOfDay: Date
    let numberOfDays: Int
    private weak var delegate: CalendarDelegate?

    @Published var events: [Date: [CalendarEvent]] = [:]
    @Published var placeholderEvent: CalendarDayEventsModulePlaceholderEvent?

    init(
        startDate: Date,
        numberOfDays: Int,
        delegate: CalendarDelegate?
    ) {
        startOfDay = Calendar.current.startOfDay(for: startDate)
        self.numberOfDays = numberOfDays
        self.delegate = delegate
    }
}

extension CalendarDayEventsModulePresenter {
    func viewDidChange(data: CalendarEventsInterval) {
        let sequence = CalendarDaysSequence(startDate: startOfDay, days: numberOfDays)
        events = sequence.reduce(into: [:]) { result, date in
            result[date] = data.events[date]?.filter { !$0.isAllDay } ?? []
        }
    }

    func viewDidSelectTimeSlot(
        dayIndex: Int,
        startTimeInterval: TimeInterval,
        duration: TimeInterval
    ) {
        guard let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startOfDay) else {
            return
        }
        let startTimestamp = date.timeIntervalSince1970 + startTimeInterval
        let endTimestamp = startTimestamp + duration
        let dateInterval = DateInterval(
            start: Date(timeIntervalSince1970: startTimestamp),
            end: Date(timeIntervalSince1970: endTimestamp)
        )
        placeholderEvent = CalendarDayEventsModulePlaceholderEvent(dateInterval: dateInterval)
        delegate?.calendarDidSelect(dateInterval: dateInterval)
    }

    func viewDidSelectEvent(with id: CalendarEvent.ID) {
        delegate?.calendarDidSelectEvent(with: id)
    }
}
