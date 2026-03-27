import Eventually
import SwiftUI

struct CalendarDayEventsView: View {
    private enum Constants {
        static var scrollViewInsets: EdgeInsets {
            EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 0)
        }

        static var eventsViewInsets: EdgeInsets {
            EdgeInsets(top: 0, leading: 38, bottom: 0, trailing: 0)
        }

        static var eventsDayViewInsets: EdgeInsets {
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5)
        }

        static var hourSlotHeightRange: ClosedRange<CGFloat> {
            40 ... 100
        }
    }

    private let startOfDay: Date
    private let numberOfDays: Int
    @Binding private var data: CalendarEventsInterval
    @Binding private var contentOffset: CGPoint?
    private weak var delegate: CalendarDelegate?

    private let dateSequence: CalendarDaysSequence
    private let scrollCoordinateSpaceName = "scrollViewContent"
    @State var events: [Date: [CalendarEvent]] = [:]
    @State var placeholderEvent: CalendarDayEventsPlaceholderEvent?
    @State private var hourSlotHeight: CGFloat = 60
    @State private var timelineWidth: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    private var daySlotWidth: CGFloat {
        timelineWidth / CGFloat(numberOfDays)
    }

    private let timeFormatStyle = Date.FormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .locale(Locale.time24Hour)

    init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<CalendarEventsInterval>,
        contentOffset: Binding<CGPoint?>,
        delegate: CalendarDelegate?
    ) {
        startOfDay = startDate
        self.numberOfDays = numberOfDays
        _data = data
        _contentOffset = contentOffset
        self.delegate = delegate
        dateSequence = CalendarDaysSequence(startDate: startDate, days: numberOfDays)
    }

    var body: some View {
        ScrollView(.vertical) {
            ZStack {
                hoursGridView()
                eventsLayoutView()
                    .overlay(alignment: .topLeading) {
                        if let event = placeholderEvent {
                            let frame = event.frame(
                                hourSlotHeight: hourSlotHeight,
                                daySlotWidth: daySlotWidth,
                                insets: UIEdgeInsets(from: Constants.eventsDayViewInsets),
                                initialDate: startOfDay
                            )
                            CalendarDayEventsEventPlaceholderView(
                                coordinateSpace: .named(scrollCoordinateSpaceName)
                            )
                            .frame(width: frame.width, height: frame.height)
                            .offset(x: frame.minX, y: frame.minY)
                            .padding(Constants.eventsDayViewInsets)
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
                    .padding(Constants.eventsViewInsets)
            }
            .padding(Constants.scrollViewInsets)
            .scrollViewPosition(Binding(get: {
                contentOffset ?? calculateInitialContentOffset(currentDate: .now)
            }, set: {
                contentOffset = $0
            }))
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { newValue in
            scrollViewHeight = newValue.height
        }
        .onChange(of: data, initial: true) {
            events = dateSequence.reduce(into: [:]) { result, date in
                result[date] = data.events[date]?.filter { !$0.isAllDay } ?? []
            }
        }
    }

    private func tapGesture() -> some Gesture {
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

    private func eventsLayoutView() -> some View {
        HStack(spacing: 0) {
            let data = Array(dateSequence.enumerated())
            ForEach(data, id: \.element) { index, date in
                EventuallyLayout(
                    startOfDay: date,
                    hourSlotHeight: hourSlotHeight
                ) {
                    if let events = events[date] {
                        ForEach(events, id: \.id) { event in
                            Button(action: {
                                delegate?.calendarDidSelectEvent(with: event.id)
                            }) {
                                CalendarDayEventsEventView(event: event)
                            }
                            .eventuallyDateIntervalLayout(event.dateInterval)
                        }
                    }
                }
                .padding(Constants.eventsDayViewInsets)
                .overlay(alignment: .top) {
                    TimelineView(.everyMinute) { context in
                        if date.isInSameDay(as: context.date) {
                            timelineMarker(startOfDay: date, date: context.date)
                        }
                    }
                }

                if (numberOfDays - 1) != index {
                    Color.black.opacity(0.8)
                        .frame(maxHeight: .infinity)
                        .frame(width: 1)
                }
            }
        }
    }

    private func hoursGridView() -> some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 24, id: \.self) { index in
                timeSlotView(index: index)
                    .padding(.bottom, hourSlotHeight)
            }
            timeSlotView(index: 0)
        }
    }

    @ViewBuilder
    private func timeSlotView(index: Int) -> some View {
        HStack(spacing: 6) {
            let x = TimeInterval(3600 * Double(index))
            let date = startOfDay.addingTimeInterval(x)
            Text(date.formatted(timeFormatStyle))
                .font(.system(.caption))
                .fixedSize()
                .frame(width: 32, alignment: .trailing)
            Color.black.opacity(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
        .frame(height: 0)
    }

    @ViewBuilder
    private func timelineMarker(startOfDay: Date, date: Date) -> some View {
        let pointsPerMinute = hourSlotHeight / 60
        let minutesFromMidnight = date.timeIntervalSince(startOfDay) / 60
        let offsetY = minutesFromMidnight * pointsPerMinute
        ZStack(alignment: .leading) {
            Color.blue
                .frame(height: 1)
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
                .offset(x: -4)
        }
        .frame(height: 0)
        .offset(y: offsetY)
    }

    private func calculateInitialContentOffset(currentDate: Date) -> CGPoint {
        let pointsPerMinute = hourSlotHeight / 60
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let minutesFromMidnight = currentDate.timeIntervalSince(startOfDay) / 60
        let currentDateOffsetY = minutesFromMidnight * pointsPerMinute
        let maxScrollOffsetY = hourSlotHeight * 24 + Constants.scrollViewInsets.top + Constants.scrollViewInsets.bottom - scrollViewHeight
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
        guard let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startOfDay) else {
            return
        }
        let startTimestamp = date.timeIntervalSince1970 + startTimeInterval
        let endTimestamp = startTimestamp + duration
        let dateInterval = DateInterval(
            start: Date(timeIntervalSince1970: startTimestamp),
            end: Date(timeIntervalSince1970: endTimestamp)
        )
        placeholderEvent = CalendarDayEventsPlaceholderEvent(dateInterval: dateInterval)
        delegate?.calendarDidSelect(dateInterval: dateInterval)
    }
}
