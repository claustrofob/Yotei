//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import SwiftUI

public struct YoteiAllDayEventsTopView<EventContent: View, MoreEventsContent: View>: View {
    private let numberOfDays: Int
    @Binding private var data: YoteiEventsInterval
    private weak var delegate: YoteiDelegate?
    @ViewBuilder private let eventContent: (YoteiEvent) -> EventContent
    @ViewBuilder private let moreEventsContent: (Int) -> MoreEventsContent

    private let dateSequence: YoteiDaysSequence

    @State private var otherEventsCount: [Date: Int] = [:]
    @State private var viewData: [[YoteiAllDayEventsTopViewModel]] = []

    public init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<YoteiEventsInterval>,
        delegate: YoteiDelegate?,
        @ViewBuilder eventContent: @escaping (YoteiEvent) -> EventContent = { event in
            YoteiAllDayEventDefaultView(event: event)
        },
        @ViewBuilder moreEventsContent: @escaping (Int) -> MoreEventsContent = { count in
            YoteiAllDayMoreEventsDefaultView(moreEventsCount: count)
        }
    ) {
        _data = data
        self.numberOfDays = numberOfDays
        self.delegate = delegate
        self.eventContent = eventContent
        self.moreEventsContent = moreEventsContent
        dateSequence = YoteiDaysSequence(startDate: startDate, days: numberOfDays)
    }

    public var body: some View {
        ZStack {
            if !viewData.isEmpty {
                eventsGridView()
                    .overlay {
                        dayButtonsView()
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 2, trailing: 0))
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: data, initial: true, isAsync: true) {
            let events = dateSequence.reduce(into: [Date: [YoteiEvent]]()) { result, date in
                guard let events = data.events[date]?.filter(\.isAllDay), !events.isEmpty else {
                    return
                }
                result[date] = events
            }
            generateViewData(for: events)
        }
    }
}

private extension YoteiAllDayEventsTopView {
    func eventsGridView() -> some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 2) {
            ForEach(0 ..< viewData.count, id: \.self) { rowIndex in
                let rowData = viewData[rowIndex]
                GridRow {
                    ForEach(rowData, id: \.id) { item in
                        switch item {
                        case let .event(event: event, cols: cols):
                            eventContent(event)
                                .gridCellColumns(cols)
                        case .empty:
                            emptyView()
                        }
                    }
                }
            }

            GridRow {
                ForEach(dateSequence, id: \.self) { date in
                    if let count = otherEventsCount[date], count > 0 {
                        moreEventsContent(count)
                    } else {
                        emptyView()
                    }
                }
            }
        }
    }

    func dayButtonsView() -> some View {
        HStack(spacing: 0) {
            ForEach(dateSequence, id: \.self) { date in
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
                let date = dateSequence[day]
                if
                    !events[date, default: []].isEmpty,
                    let event = events[date]?.removeFirst()
                {
                    let eventDateInterval = event.displayableDateInterval()
                    if
                        processedEventIDs.contains(event.id) ||
                        (!data.isEmpty && !eventDateInterval.start.isInSameDay(as: date))
                    {
                        continue
                    }
                    let dateInterval = DateInterval(start: date, end: eventDateInterval.end)
                    let durationInDays = min(dateInterval.durationInDays + 1, numberOfDays - day)
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
