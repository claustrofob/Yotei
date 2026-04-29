//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDragEventView<Content: View, Data: YoteiEventData>: View {
    @Binding private var data: YoteiEventsInterval<Data>
    @ViewBuilder private let content: () -> Content

    @State private var timelineDayFrames = [Date: CGRect]()
    @State private var timelineDayEventFrames = [Date: [EventFrame]]()

    @State private var activeEvent: YoteiEvent<Data>?
    @State private var isDragging = false
    @State private var isDraggingEvent = false

    private var calendarScrollDisabled: Bool {
        isDraggingEvent
    }

    // disable long press if there is an active event
    private var longPressMinDuration: Double {
        activeEvent == nil ? 0.5 : 0
    }

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        self.content = content
    }

    public var body: some View {
        let combined = LongPressGesture(minimumDuration: longPressMinDuration)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    guard let drag else { return }

                    if !isDragging {
                        isDragging = true
                        let foundEvent = findActiveEvent(under: drag.startLocation)
                        if activeEvent == nil {
                            activeEvent = foundEvent
                        }

                        if foundEvent != nil {
                            isDraggingEvent = foundEvent == activeEvent
                        }
                    }

                default:
                    isDraggingEvent = false
                    isDragging = false
                }
            }
            .onEnded { _ in
                isDraggingEvent = false
                isDragging = false
            }
        GeometryReader { proxy in
            content()
                .onPreferenceChange(DayTimelineAnchorKey.self) { timelineAnchors in
                    timelineDayFrames = timelineAnchors.mapValues { proxy[$0] }
                }
                .onPreferenceChange(EventTimelineFramesKey.self) { eventFrames in
                    timelineDayEventFrames = eventFrames
                }
                .environment(\.calendarScrollDisabled, calendarScrollDisabled)
        }
        .overlay {}
        .simultaneousGesture(combined)
        .highPriorityGesture(TapGesture())
    }

    private func findActiveEvent(under location: CGPoint) -> YoteiEvent<Data>? {
        let dateFrame = timelineDayFrames.first { _, value in
            value.contains(location)
        }

        guard let dateFrame, let eventFrames = timelineDayEventFrames[dateFrame.key] else {
            return nil
        }

        let localLocation = CGPoint(x: location.x - dateFrame.value.minX, y: location.y - dateFrame.value.minY)
        let eventFrame = eventFrames.sorted(using: KeyPathComparator(\.date)).last { frame in
            frame.frame.contains(localLocation)
        }
        guard let eventFrame else {
            return nil
        }

        return data.events[dateFrame.key]?.first(where: { $0.id == eventFrame.id })
    }
}

struct DayTimelineAnchorKey: PreferenceKey {
    static let defaultValue: [Date: Anchor<CGRect>] = [:]
    static func reduce(value: inout [Date: Anchor<CGRect>], nextValue: () -> [Date: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct EventTimelineFramesKey: PreferenceKey {
    static let defaultValue: [Date: [EventFrame]] = [:]
    static func reduce(value: inout [Date: [EventFrame]], nextValue: () -> [Date: [EventFrame]]) {
        value.merge(nextValue(), uniquingKeysWith: {
            $0 + $1
        })
    }
}

// ----------------

struct EventFrame: Equatable, Sendable {
    let id: String
    let date: Date
    let frame: CGRect
}

// -----------------

enum CalendarScrollDisableddKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var calendarScrollDisabled: Bool {
        get {
            self[CalendarScrollDisableddKey.self]
        } set {
            self[CalendarScrollDisableddKey.self] = newValue
        }
    }
}
