//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import SwiftUI

public struct YoteiAllDayEventsTopView<ViewFactory: YoteiAllDayEventsTopViewFactoryProtocol>: View {
    @Environment(\.calendar) private var calendar

    private let startDate: Date
    private let numberOfDays: Int
    @Binding private var data: YoteiEventsInterval
    private weak var delegate: YoteiDelegate?
    private let viewFactory: ViewFactory

    public init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<YoteiEventsInterval>,
        delegate: YoteiDelegate?,
        viewFactory: ViewFactory = YoteiAllDayEventsTopViewFactory()
    ) {
        _data = data
        self.startDate = startDate
        self.numberOfDays = numberOfDays
        self.delegate = delegate
        self.viewFactory = viewFactory
    }

    public var body: some View {
        MainView(
            numberOfDays: numberOfDays,
            data: $data,
            delegate: delegate,
            viewFactory: viewFactory,
            daysSequence: YoteiDaysSequence(startDate: startDate, days: numberOfDays, calendar: calendar)
        )
    }
}

private extension YoteiAllDayEventsTopView {
    struct MainView: View {
        @Environment(\.calendar) private var calendar

        let numberOfDays: Int
        @Binding var data: YoteiEventsInterval
        weak var delegate: YoteiDelegate?
        let viewFactory: ViewFactory
        let daysSequence: YoteiDaysSequence

        @State private var otherEventsCount: [Date: Int] = [:]
        @State private var viewData: [[YoteiAllDayEventsTopViewModel]] = []

        var body: some View {
            ZStack {
                if !viewData.isEmpty {
                    eventsGridView()
                        .overlay {
                            dayButtonsView()
                        }
                        .padding(viewFactory.insets())
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: data, initial: true, isAsync: true) {
                let events = daysSequence.reduce(into: [Date: [YoteiEvent]]()) { result, date in
                    guard let events = data.events[date]?.filter(\.isAllDay), !events.isEmpty else {
                        return
                    }
                    result[date] = events
                }
                generateViewData(for: events)
            }
        }

        func eventsGridView() -> some View {
            Grid(
                horizontalSpacing: viewFactory.interitemHorizontalSpacing(),
                verticalSpacing: viewFactory.interitemVerticalSpacing()
            ) {
                ForEach(0 ..< viewData.count, id: \.self) { rowIndex in
                    let rowData = viewData[rowIndex]
                    GridRow {
                        ForEach(rowData, id: \.id) { item in
                            switch item {
                            case let .event(event: event, cols: cols):
                                viewFactory.eventView(event: event)
                                    .gridCellColumns(cols)
                            case .empty:
                                emptyView()
                            }
                        }
                    }
                }

                GridRow {
                    ForEach(daysSequence, id: \.self) { date in
                        if let count = otherEventsCount[date], count > 0 {
                            viewFactory.moreEventsView(count: count)
                        } else {
                            emptyView()
                        }
                    }
                }
            }
        }

        func dayButtonsView() -> some View {
            HStack(spacing: 0) {
                ForEach(daysSequence, id: \.self) { date in
                    Button(action: {
                        delegate?.calendarDidSelectAllDay(date: date)
                    }) {
                        Color.clear
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.frame(maxWidth: .infinity)
        }

        func emptyView() -> some View {
            Color.clear
                .frame(height: 0)
                .frame(maxWidth: .infinity)
        }

        func generateViewData(for events: [Date: [YoteiEvent]]) {
            var events = events
            guard !events.isEmpty else {
                viewData = []
                return
            }
            var processedEventIDs = Set<YoteiEvent.ID>()
            viewData = (0 ..< 2).map { _ in
                var day = 0
                var data = [YoteiAllDayEventsTopViewModel]()
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
            otherEventsCount = events.reduce(into: [:]) { result, pair in
                result[pair.key] = pair.value.count
            }
        }
    }
}
