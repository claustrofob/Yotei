//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Eventually
import SwiftUI

public struct YoteiDayEventsView<ViewFactory: YoteiDayEventsViewFactoryProtocol>: View {
    @Environment(\.calendar) private var calendar

    private let dayDate: Date
    private let numberOfDays: Int
    @Binding private var data: YoteiEventsInterval
    @Binding private var contentOffset: CGPoint?
    private weak var delegate: YoteiDelegate?
    private let viewFactory: ViewFactory

    private var dateSequence: YoteiDaysSequence {
        YoteiDaysSequence(startDate: dayDate, days: numberOfDays, calendar: calendar)
    }

    private let scrollCoordinateSpaceName = "scrollViewContent"
    @State private var events: [Date: [YoteiEvent]] = [:]
    @State private var placeholderEvent: YoteiDayEventsPlaceholderEvent?
    @State private var timelineWidth: CGFloat = 0
    private var daySlotWidth: CGFloat {
        timelineWidth / CGFloat(numberOfDays)
    }

    private var hourSlotHeight: CGFloat {
        viewFactory.hourSlotHeight()
    }

    private var startOfDay: Date {
        calendar.startOfDay(for: dayDate)
    }

    public init(
        dayDate: Date,
        numberOfDays: Int,
        data: Binding<YoteiEventsInterval>,
        contentOffset: Binding<CGPoint?>,
        delegate: YoteiDelegate?,
        viewFactory: ViewFactory = YoteiDayEventsViewFactory()
    ) {
        self.dayDate = dayDate
        self.numberOfDays = numberOfDays
        _data = data
        _contentOffset = contentOffset
        self.delegate = delegate
        self.viewFactory = viewFactory
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                ZStack {
                    HoursGridView(
                        startOfDay: startOfDay,
                        viewFactory: viewFactory
                    )
                    EventsLayoutView(
                        events: events,
                        dateSequence: dateSequence,
                        numberOfDays: numberOfDays,
                        viewFactory: viewFactory
                    )
                    .overlay(alignment: .topLeading) {
                        if let event = placeholderEvent {
                            PlaceHolderView(
                                startOfDay: startOfDay,
                                event: event,
                                daySlotWidth: daySlotWidth,
                                scrollCoordinateSpaceName: scrollCoordinateSpaceName,
                                viewFactory: viewFactory
                            )
                        }
                    }
                    .onGeometryChange(for: CGSize.self) {
                        $0.size
                    } action: { newValue in
                        timelineWidth = newValue.width
                    }
                    .contentShape(Rectangle())
                    .gesture(tapGesture())
                    .coordinateSpace(name: scrollCoordinateSpaceName)
                    .padding(viewFactory.insetsForViewsLayout())
                }
                .padding(viewFactory.insetsForScrollView())
                .scrollViewPosition(Binding(get: {
                    contentOffset ?? calculateInitialContentOffset(currentDate: .now, scrollViewHeight: proxy.size.height)
                }, set: {
                    contentOffset = $0
                }))
            }
        }
        .onChange(of: data, initial: true, isAsync: true) {
            events = dateSequence.reduce(into: [:]) { result, date in
                result[date] = data.events[date]?.filter { !$0.isAllDay } ?? []
            }
        }
    }
}

private extension YoteiDayEventsView {
    struct HoursGridView: View {
        @Environment(\.calendar) private var calendar

        let startOfDay: Date
        let viewFactory: ViewFactory

        var body: some View {
            VStack(spacing: 0) {
                ForEach(0 ..< 24, id: \.self) { index in
                    timeSlotView(index: index)
                        .padding(.bottom, viewFactory.hourSlotHeight())
                }
                timeSlotView(index: 0)
            }
        }

        @ViewBuilder
        private func timeSlotView(index: Int) -> some View {
            let x = TimeInterval(3600 * Double(index))
            let date = startOfDay.addingTimeInterval(x)
            viewFactory.timeSlotView(date: date)
                .frame(height: 0)
        }
    }

    struct EventsLayoutView: View {
        @Environment(\.calendar) private var calendar

        let events: [Date: [YoteiEvent]]
        let dateSequence: YoteiDaysSequence
        let numberOfDays: Int
        let viewFactory: ViewFactory
        weak var delegate: YoteiDelegate?

        var body: some View {
            HStack(spacing: 0) {
                let data = Array(dateSequence.enumerated())
                ForEach(data, id: \.element) { index, date in
                    EventuallyLayout(
                        startOfDay: date,
                        hourSlotHeight: viewFactory.hourSlotHeight()
                    ) {
                        if let events = events[date] {
                            ForEach(events, id: \.id) { event in
                                Button(action: {
                                    delegate?.calendarDidSelectEvent(with: event.id)
                                }) {
                                    viewFactory.eventView(event: event)
                                }
                                .eventuallyDateIntervalLayout(event.dateInterval)
                                .zIndex(event.start.timeIntervalSince1970)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .top) {
                        TimelineView(.everyMinute) { context in
                            if date.isInSameDay(as: context.date, in: calendar) {
                                timelineMarker(startOfDay: date, date: context.date)
                            }
                        }
                    }

                    if (numberOfDays - 1) != index {
                        viewFactory.daysDelimiterView()
                    }
                }
            }
            .buttonStyle(.plain)
        }

        @ViewBuilder
        private func timelineMarker(startOfDay: Date, date: Date) -> some View {
            let pointsPerMinute = viewFactory.hourSlotHeight() / 60
            let minutesFromMidnight = date.timeIntervalSince(startOfDay) / 60
            let offsetY = minutesFromMidnight * pointsPerMinute
            viewFactory.currentTimeMarkerView()
                .frame(height: 0)
                .offset(y: offsetY)
        }
    }

    struct PlaceHolderView: View {
        let startOfDay: Date
        let event: YoteiDayEventsPlaceholderEvent
        let daySlotWidth: CGFloat
        let scrollCoordinateSpaceName: String
        let viewFactory: ViewFactory

        var body: some View {
            let frame = event.frame(
                hourSlotHeight: viewFactory.hourSlotHeight(),
                daySlotWidth: daySlotWidth,
                initialDate: startOfDay
            )
            viewFactory.placeholderView(
                coordinateSpace: .named(scrollCoordinateSpaceName)
            )
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
        }
    }
}

private extension YoteiDayEventsView {
    func tapGesture() -> some Gesture {
        SpatialTapGesture(coordinateSpace: .named(scrollCoordinateSpaceName)).onEnded { value in
            let dayIndex = Int(value.location.x / daySlotWidth)
            let secondsPerPoint = 3600 / hourSlotHeight
            let yPosition = min(max(value.location.y, 0), hourSlotHeight * 24)
            let centerTimeInterval = yPosition * secondsPerPoint
            let halfAnHourInterval: TimeInterval = 1800
            let startTimeInterval = CGFloat(Int(centerTimeInterval / halfAnHourInterval)) * halfAnHourInterval
            didSelectTimeSlot(
                dayIndex: dayIndex,
                startTimeInterval: startTimeInterval,
                duration: 3600
            )
        }
    }

    func calculateInitialContentOffset(currentDate: Date, scrollViewHeight: CGFloat) -> CGPoint {
        let pointsPerMinute = hourSlotHeight / 60
        let startOfDay = calendar.startOfDay(for: currentDate)
        let minutesFromMidnight = currentDate.timeIntervalSince(startOfDay) / 60
        let currentDateOffsetY = minutesFromMidnight * pointsPerMinute
        let scrollViewInsets = viewFactory.insetsForScrollView()
        let maxScrollOffsetY = hourSlotHeight * 24 + scrollViewInsets.top + scrollViewInsets.bottom - scrollViewHeight
        return CGPoint(
            x: 0,
            y: min(max(currentDateOffsetY - scrollViewHeight / 3, 0), maxScrollOffsetY)
        )
    }

    func didSelectTimeSlot(
        dayIndex: Int,
        startTimeInterval: TimeInterval,
        duration: TimeInterval
    ) {
        guard let date = calendar.date(byAdding: .day, value: dayIndex, to: startOfDay) else {
            return
        }
        let startTimestamp = date.timeIntervalSince1970 + startTimeInterval
        let endTimestamp = startTimestamp + duration
        let dateInterval = DateInterval(
            start: Date(timeIntervalSince1970: startTimestamp),
            end: Date(timeIntervalSince1970: endTimestamp)
        )
        placeholderEvent = YoteiDayEventsPlaceholderEvent(dateInterval: dateInterval, calendar: calendar)
        delegate?.calendarDidSelect(dateInterval: dateInterval)
    }
}
