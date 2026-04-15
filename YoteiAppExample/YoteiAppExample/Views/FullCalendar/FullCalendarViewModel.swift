//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Combine
import Foundation
import Yotei

final class FullCalendarViewModelModel: ObservableObject {
    private enum Constants {
        static var monthIntervalMinDay: Int { -7 }
        static var monthIntervalMaxDay: Int { 12 }
    }

    private let eventsLocalRepository: EventsLocalRepositoryProtocol
    private var monthInterval: DateInterval?
    // an interval, that was successfully fetched. This is used to determine the next interval to fetch.
    private var lastRemoteLoadedDateInterval: DateInterval?

    @Published var focusedDate = Date()
    @Published var data = YoteiEventsInterval()
    @Published var viewType: CalendarViewType = .day

    init(eventsLocalRepository: EventsLocalRepositoryProtocol) {
        self.eventsLocalRepository = eventsLocalRepository
    }

    private func fetchRemoteEvents(in dateInterval: DateInterval) {
        var displayLoadingInterval: DateInterval? = dateInterval
        if
            let lastRemoteLoadedDateInterval,
            dateInterval.intersects(lastRemoteLoadedDateInterval)
        {
            if
                lastRemoteLoadedDateInterval.start <= dateInterval.start,
                lastRemoteLoadedDateInterval.end < dateInterval.end
            {
                displayLoadingInterval = DateInterval(start: lastRemoteLoadedDateInterval.end, end: dateInterval.end)
            } else if
                lastRemoteLoadedDateInterval.start > dateInterval.start,
                lastRemoteLoadedDateInterval.end >= dateInterval.end
            {
                displayLoadingInterval = DateInterval(start: dateInterval.start, end: lastRemoteLoadedDateInterval.start)
            } else if
                lastRemoteLoadedDateInterval.start <= dateInterval.start,
                lastRemoteLoadedDateInterval.end >= dateInterval.end
            {
                displayLoadingInterval = nil
            }
        }

        data.dateLoadingInterval = displayLoadingInterval

        // fetch and save events to local DB
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            lastRemoteLoadedDateInterval = dateInterval
            data.dateLoadingInterval = nil
        }
    }

    private func fetchLocalEvents(in dateInterval: DateInterval) {
        Task {
            data.events = await eventsLocalRepository.events(in: dateInterval)
        }
    }
}

extension FullCalendarViewModelModel {
    func viewDidChangeFocusedDate() {
        let monthInterval = Calendar.current.dateInterval(of: .month, for: focusedDate)!
        guard monthInterval != self.monthInterval else {
            return
        }

        self.monthInterval = monthInterval

        let startDate = Calendar.current.date(
            byAdding: .day,
            value: Constants.monthIntervalMinDay,
            to: monthInterval.start
        )!
        let endDate = Calendar.current.date(
            byAdding: .day,
            value: Constants.monthIntervalMaxDay,
            to: monthInterval.end
        )!
        let dateInterval = DateInterval(start: startDate, end: endDate)

        data.dateInterval = dateInterval
        data.monthInterval = monthInterval

        fetchRemoteEvents(in: dateInterval)
        fetchLocalEvents(in: dateInterval)
    }

    func viewDidSelectToday() {
        focusedDate = Date()
    }
}
