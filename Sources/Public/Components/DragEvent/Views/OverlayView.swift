//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

extension YoteiDragEventView {
    struct OverlayView: View {
        private enum Constants {
            static var autoScrollEdgeThreshold: CGFloat {
                80
            }

            static var maxAutoScrollVelocity: CGFloat {
                8
            }

            static var pageFlipEdgeThreshold: CGFloat {
                40
            }

            static var pageFlipCooldown: TimeInterval {
                0.6
            }
        }

        @Environment(\.calendar) private var calendar
        @Environment(\.yoteiDelegate) private var delegate

        private let data: YoteiEventsInterval<Data>
        @Binding private var contentOffset: CGPoint?
        @Binding private var focusedDate: Date
        private let dragEvent: DragEvent
        private let viewFactory: ViewFactory
        @ViewBuilder private let content: () -> Content

        @State private var timelineDayFrames = [Date: CGRect]()
        @State private var timelineDayEventFrames = [Date: [EventFrame]]()

        @State private var activeDate: Date?
        @State private var activeEvent: YoteiEvent<Data>?
        @State private var translation: CGPoint = .zero
        @State private var hapticFeedbackGenerator = UISelectionFeedbackGenerator()

        @State private var viewSize: CGSize = .zero
        @State private var scrollSize: CGSize = .zero
        @State private var eventFrame: CGRect?
        @State private var autoScrollVelocity: CGFloat = 0
        @State private var displayLink: DisplayLink?
        @State private var pagesCalendarComponent: Calendar.Component?
        @State private var lastPageFlipDate: Date?
        @State private var hourSlotHeight: CGFloat = 0

        private var totalContentHeight: CGFloat {
            24 * hourSlotHeight
        }

        init(
            data: YoteiEventsInterval<Data>,
            contentOffset: Binding<CGPoint?>,
            focusedDate: Binding<Date>,
            dragEvent: DragEvent,
            viewFactory: ViewFactory,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.data = data
            _contentOffset = contentOffset
            _focusedDate = focusedDate
            self.dragEvent = dragEvent
            self.viewFactory = viewFactory
            self.content = content
        }

        var body: some View {
            GeometryReader { proxy in
                content()
                    .onPreferenceChange(DayTimelineAnchorKey.self) { timelineAnchors in
                        timelineDayFrames = timelineAnchors.mapValues { proxy[$0] }
                    }
                    .onPreferenceChange(EventTimelineFramesKey.self) { eventFrames in
                        timelineDayEventFrames = eventFrames
                    }
                    .onPreferenceChange(EventScrollViewSizeKey.self) { size in
                        scrollSize = size
                    }
                    .onPreferenceChange(PagesCalendarComponentKey.self) { component in
                        pagesCalendarComponent = component
                    }
                    .onPreferenceChange(HourSlotHeightKey.self) { height in
                        hourSlotHeight = height
                    }
            }
            .onChange(of: dragEvent) { value in
                switch value {
                case let .began(location):
                    guard let date = findActiveDate(under: location) else {
                        return
                    }
                    activeDate = date
                    activeEvent = findActiveEvent(date: date, under: location) // TODO: or create a placeholder event
                    if let activeEvent {
                        eventFrame = initialEventFrame(event: activeEvent, startOfDay: date)
                    }
                    hapticFeedbackGenerator.selectionChanged()
                case let .changed(translation, location):
                    guard activeEvent != nil else {
                        return
                    }
                    if let date = findActiveDate(under: location) {
                        activeDate = date
                    }
                    self.translation = translation
                    updateAutoScroll(fingerY: location.y)
                    updatePageFlip(fingerX: location.x)
                case .ended:
                    updateEventInterval()
                    translation = .zero
                    activeDate = nil
                    activeEvent = nil
                    stopAutoScroll()
                    eventFrame = nil
                    lastPageFlipDate = nil
                }
            }
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                viewSize = newValue
            }
            .overlay(alignment: .topLeading) {
                if let activeEvent, let eventFrame {
                    viewFactory.eventView(event: activeEvent)
                        .frame(width: eventFrame.width, height: eventFrame.height)
                        .offset(
                            x: eventFrame.origin.x + translation.x,
                            y: eventFrame.origin.y + translation.y
                        )
                        .allowsHitTesting(false)
                }
            }
            .onDisappear {
                stopAutoScroll()
            }
            .clipped()
            .ignoresSafeArea()
        }

        private func findActiveDate(under location: CGPoint) -> Date? {
            timelineDayFrames.first(where: {
                $0.value.contains(location)
            })?.key
        }

        private func findActiveEvent(date: Date, under location: CGPoint) -> YoteiEvent<Data>? {
            guard let dateFrame = timelineDayFrames[date], let eventFrames = timelineDayEventFrames[date] else {
                return nil
            }

            let localLocation = CGPoint(x: location.x - dateFrame.minX, y: location.y - dateFrame.minY)
            let eventFrame = eventFrames.sorted(using: KeyPathComparator(\.date)).last { frame in
                frame.frame.contains(localLocation)
            }
            guard let eventFrame else {
                return nil
            }

            return data.events[date]?.first(where: { $0.id == eventFrame.id })
        }

        private func updateAutoScroll(fingerY: CGFloat) {
            guard viewSize.height > 0 else { return }
            let topThreshold = Constants.autoScrollEdgeThreshold
            let bottomThreshold = viewSize.height - Constants.autoScrollEdgeThreshold
            let velocity: CGFloat
            if fingerY < topThreshold {
                let proximity = min(1, max(0, (topThreshold - fingerY) / Constants.autoScrollEdgeThreshold))
                velocity = -Constants.maxAutoScrollVelocity * proximity
            } else if fingerY > bottomThreshold {
                let proximity = min(1, max(0, (fingerY - bottomThreshold) / Constants.autoScrollEdgeThreshold))
                velocity = Constants.maxAutoScrollVelocity * proximity
            } else {
                velocity = 0
            }

            autoScrollVelocity = velocity
            if velocity != 0 {
                startAutoScroll()
            } else {
                stopAutoScroll()
            }
        }

        private func startAutoScroll() {
            guard displayLink == nil else { return }
            displayLink = DisplayLink {
                let currentY = contentOffset?.y ?? 0
                let maxY = max(0, totalContentHeight - scrollSize.height)
                let proposedY = max(0, min(maxY, currentY + autoScrollVelocity))
                let actualDelta = proposedY - currentY

                guard actualDelta != 0 else { return }
                contentOffset = CGPoint(x: 0, y: proposedY)
            }
        }

        private func stopAutoScroll() {
            autoScrollVelocity = 0
            displayLink?.invalidate()
            displayLink = nil
        }

        private func updatePageFlip(fingerX: CGFloat) {
            guard let pagesCalendarComponent, viewSize.width > 0 else { return }

            let direction: Int
            if fingerX < Constants.pageFlipEdgeThreshold {
                direction = -1
            } else if fingerX > viewSize.width - Constants.pageFlipEdgeThreshold {
                direction = 1
            } else {
                lastPageFlipDate = nil
                return
            }

            let now = Date()
            lastPageFlipDate = lastPageFlipDate ?? now
            if let lastPageFlipDate, now.timeIntervalSince(lastPageFlipDate) < Constants.pageFlipCooldown {
                return
            }

            guard let newDate = calendar.date(
                byAdding: pagesCalendarComponent,
                value: direction,
                to: focusedDate
            ) else { return }

            focusedDate = newDate
            lastPageFlipDate = nil
        }

        private func initialEventFrame(event: YoteiEvent<Data>, startOfDay: Date) -> CGRect? {
            guard let dateFrame = timelineDayFrames[startOfDay] else {
                return nil
            }

            let pointsPerSecond = hourSlotHeight / 3600
            let originY = CGFloat(event.start.timeIntervalSince(startOfDay)) * pointsPerSecond
            let height = event.dateInterval.duration * pointsPerSecond
            return CGRect(
                x: dateFrame.minX,
                y: dateFrame.minY + originY,
                width: dateFrame.width,
                height: height
            )
        }

        private func updateEventInterval() {
            guard
                let activeDate,
                let activeEvent,
                let eventFrame,
                let dayFrame = timelineDayFrames[activeDate]
            else {
                return
            }

            let newOriginPoint = CGPoint(
                x: eventFrame.origin.x + translation.x,
                y: eventFrame.origin.y + translation.y
            )

            let eventYOffset = newOriginPoint.y - dayFrame.minY
            let secondsPerPoint = 3600 / hourSlotHeight

            let snapToSeconds = viewFactory.snapToMinutes() * 60
            let secondsFromDayMidnight = CGFloat(Int(secondsPerPoint * eventYOffset) / snapToSeconds * snapToSeconds)

            let eventDuration = activeEvent.dateInterval.duration
            let start = activeDate.addingTimeInterval(secondsFromDayMidnight)
            let end = start.addingTimeInterval(eventDuration)

            delegate?.calendarDidUpdateEvent(
                with: activeEvent.id,
                oldDateInterval: activeEvent.dateInterval,
                newDateInterval: DateInterval(start: start, end: end)
            )
        }
    }
}
