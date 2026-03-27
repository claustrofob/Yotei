import Foundation
import SwiftUI

struct CalendarAllDayEventsTopModuleView: View {
    private let numberOfDays: Int
    @Binding private var data: CalendarEventsInterval
    private weak var delegate: CalendarDelegate?

    private let dateSequence: CalendarDaysSequence

    @State private var otherEventsCount: [Date: Int] = [:]
    @State private var viewData: [[CalendarAllDayEventsTopModuleViewModel]] = []

    init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) {
        _data = data
        self.numberOfDays = numberOfDays
        self.delegate = delegate
        dateSequence = CalendarDaysSequence(startDate: startDate, days: numberOfDays)
    }

    var body: some View {
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
        .onChange(of: data, initial: true) {
            let events = dateSequence.reduce(into: [Date: [CalendarEvent]]()) { result, date in
                guard let events = data.events[date]?.filter({ $0.isAllDay }), !events.isEmpty else {
                    return
                }
                result[date] = events
            }
            generateViewData(for: events)
        }
    }

    private func eventsGridView() -> some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 2) {
            ForEach(0 ..< viewData.count, id: \.self) { rowIndex in
                let rowData = viewData[rowIndex]
                GridRow {
                    ForEach(rowData, id: \.id) { item in
                        switch item {
                        case let .event(event: event, cols: cols):
                            eventView(event: event)
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
                        moreItemsView(count: count)
                    } else {
                        emptyView()
                    }
                }
            }
        }
    }

    private func dayButtonsView() -> some View {
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

    @ViewBuilder
    private func eventView(event: CalendarEvent) -> some View {
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.blue.opacity(0.5))
            .font(.system(.caption2))
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(.blue.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }

    private func moreItemsView(count: Int) -> some View {
        Text("+\(count)")
            .lineLimit(1)
            .foregroundStyle(.black.opacity(0.1))
            .font(.system(.caption2))
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(.black.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }

    private func emptyView() -> some View {
        Color.clear
            .frame(height: 0)
            .frame(maxWidth: .infinity)
    }

    private func generateViewData(for events: [Date: [CalendarEvent]]) {
        var events = events
        guard !events.isEmpty else {
            viewData = []
            return
        }
        var processedEventIDs = Set<CalendarEvent.ID>()
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
