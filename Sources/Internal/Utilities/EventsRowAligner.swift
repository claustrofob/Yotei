//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

actor EventsRowAligner<Data: YoteiEventData> {
    private let startDate: Date
    private let numberOfDays: Int
    private let calendar: Calendar
    private let numberOfVisibleRows: Int

    init(
        startDate: Date,
        numberOfDays: Int,
        calendar: Calendar,
        numberOfVisibleRows: Int
    ) {
        self.startDate = startDate
        self.numberOfDays = numberOfDays
        self.calendar = calendar
        self.numberOfVisibleRows = numberOfVisibleRows
    }

    func calculate(data: YoteiEventsInterval<Data>, filter: @Sendable (YoteiEvent<Data>) -> Bool) -> AlignedRowEventsData<Data> {
        let daysSequence = YoteiDaysSequence(startDate: startDate, days: numberOfDays, calendar: calendar)
        var events = daysSequence.reduce(into: [Date: [YoteiEvent]]()) { result, date in
            guard let events = data.events[date]?.filter(filter), !events.isEmpty else {
                return
            }
            result[date] = events
        }

        guard !events.isEmpty else {
            return AlignedRowEventsData(startDate: startDate)
        }

        var processedEventIDs = Set<YoteiEvent<Data>.ID>()
        let viewData = (0 ..< numberOfVisibleRows).map { _ in
            var day = 0
            var data = [AlignedRowEvent<Data>]()
            while day < numberOfDays {
                let date = daysSequence[day]
                if
                    !events[date, default: []].isEmpty,
                    let event = events[date]?.removeFirst()
                {
                    let eventDateInterval = event.displayableDateInterval()
                    if
                        processedEventIDs.contains(event.id) ||
                        (!data.isEmpty && !eventDateInterval.start.isInSameDay(as: date, in: calendar))
                    {
                        continue
                    }
                    let dateInterval = DateInterval(start: date, end: eventDateInterval.end)
                    let durationInDays = min(dateInterval.durationInDays(in: calendar) + 1, numberOfDays - day)
                    data.append(.event(event: event, cols: durationInDays))
                    day += durationInDays
                    processedEventIDs.insert(event.id)
                } else {
                    data.append(.empty(index: day))
                    day += 1
                }
            }
            return data
        }
        let extraCount = events.reduce(into: [:]) { result, pair in
            result[pair.key] = pair.value.count
        }

        return AlignedRowEventsData(
            startDate: startDate,
            events: viewData,
            extraCount: extraCount
        )
    }
}
