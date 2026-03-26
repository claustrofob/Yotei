import Foundation

final class CalendarAllDayEventsTopModulePresenter: ObservableObject {
    private lazy var dateSequence = CalendarDaysSequence(startDate: startDate, days: numberOfDays)

    let startDate: Date
    let numberOfDays: Int
    private weak var delegate: CalendarDelegate?

    @Published var otherEventsCount: [Date: Int] = [:]
    @Published var viewData: [[CalendarAllDayEventsTopModuleViewModel]] = []

    init(
        startDate: Date,
        numberOfDays: Int,
        delegate: CalendarDelegate?
    ) {
        self.startDate = startDate
        self.numberOfDays = numberOfDays
        self.delegate = delegate
    }

    private func generateViewData(for events: [Date: [CalendarEvent]]) {
        var events = events
        guard !events.isEmpty else {
            viewData = []
            return
        }
        var processedEventIDs = Set<CalendarEvent.ServerID>()
        viewData = (0 ..< 2).map { _ in
            var day = 0
            var data = [CalendarAllDayEventsTopModuleViewModel]()
            while day < numberOfDays {
                let date = dateSequence[day]
                if
                    !events[date, default: []].isEmpty,
                    let event = events[date]?.removeFirst()
                {
                    let eventDateInterval = event.displayableDateInterval()
                    if
                        processedEventIDs.contains(event.serverID) ||
                        (!data.isEmpty && !eventDateInterval.start.isInSameDay(as: date))
                    {
                        continue
                    }
                    let dateInterval = DateInterval(start: date, end: eventDateInterval.end)
                    let durationInDays = min(dateInterval.durationInDays + 1, numberOfDays - day)
                    data.append(.event(event: event, cols: durationInDays))
                    day += durationInDays
                    processedEventIDs.insert(event.serverID)
                } else {
                    data.append(.empty(index: day))
                    day += 1
                }
            }
            return data
        }
        otherEventsCount = events.reduce(into: [:]) { result, pair in
            result[pair.key] = pair.value.count
        }
    }
}

extension CalendarAllDayEventsTopModulePresenter {
    func viewDidChange(data: CalendarEventsInterval) {
        let events = dateSequence.reduce(into: [Date: [CalendarEvent]]()) { result, date in
            guard let events = data.events[date]?.filter({ $0.isAllDay }), !events.isEmpty else {
                return
            }
            result[date] = events
        }
        generateViewData(for: events)
    }

    func viewDidSelect(date: Date) {
        delegate?.calendarDidSelectAllDay(date: date)
    }
}
