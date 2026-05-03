//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDragEventView<Content: View, Data: YoteiEventData>: UIViewControllerRepresentable {
    @Binding private var data: YoteiEventsInterval<Data>
    @ViewBuilder private let content: () -> Content

    @State var dragEvent: DragEvent = .ended

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        self.content = content
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(dragEvent: $dragEvent)
    }

    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let vc = UIHostingController(rootView: content())
        vc.view.addGestureRecognizer(context.coordinator.pressGesture)
        vc.view.addGestureRecognizer(context.coordinator.panGesture)
        return vc
    }

    public func updateUIViewController(_ uiViewController: UIHostingController<Content>, context _: Context) {
        uiViewController.rootView = content()
    }
}

public extension YoteiDragEventView {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        lazy var pressGesture: UILongPressGestureRecognizer = {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            gesture.delegate = self
            return gesture
        }()

        lazy var panGesture: UIPanGestureRecognizer = {
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            gesture.delegate = self
            return gesture
        }()

        private var isLongPressActive = false

        @Binding private var dragEvent: DragEvent

        init(dragEvent: Binding<DragEvent>) {
            _dragEvent = dragEvent
            super.init()
        }

        @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            switch gesture.state {
            case .began:
                isLongPressActive = true
                let location = gesture.location(in: gesture.view)
                dragEvent = .began(location: location)
            case .ended, .cancelled, .failed:
                isLongPressActive = false
            default:
                break
            }
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                dragEvent = .changed(translation: translation)
            case .ended, .cancelled:
                dragEvent = .ended
            default:
                break
            }
        }

        // MARK: - UIGestureRecognizerDelegate

        public func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
            if gesture === panGesture { return isLongPressActive }
            return true
        }

        public func gestureRecognizer(
            _ gesture: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            (gesture === pressGesture && other === panGesture) || (gesture === panGesture && other === pressGesture)
        }
    }
}

public struct YoteiDragEventView1<Content: View, Data: YoteiEventData>: View {
    @Binding private var data: YoteiEventsInterval<Data>
    @ViewBuilder private let content: () -> Content

    @State private var timelineDayFrames = [Date: CGRect]()
    @State private var timelineDayEventFrames = [Date: [EventFrame]]()

    @State private var activeEvent: YoteiEvent<Data>?
    @State private var isDragging = false
    @State private var isDraggingEvent = false

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        self.content = content
    }

    public var body: some View {
//        let combined = LongPressGesture(minimumDuration: longPressMinDuration)
//            .sequenced(before: DragGesture(minimumDistance: 0))
//            .onChanged { value in
//                switch value {
//                case .second(true, let drag):
//                    guard let drag else { return }
//
//                    if !isDragging {
//                        isDragging = true
//                        let foundEvent = findActiveEvent(under: drag.startLocation)
//                        if activeEvent == nil {
//                            activeEvent = foundEvent
//                        }
//
//                        if foundEvent != nil {
//                            isDraggingEvent = foundEvent == activeEvent
//                        }
//                    }
//
//                default:
//                    isDraggingEvent = false
//                    isDragging = false
//                }
//            }
//            .onEnded { _ in
//                isDraggingEvent = false
//                isDragging = false
//            }
        GeometryReader { proxy in
            content()
                .onPreferenceChange(DayTimelineAnchorKey.self) { timelineAnchors in
                    timelineDayFrames = timelineAnchors.mapValues { proxy[$0] }
                }
                .onPreferenceChange(EventTimelineFramesKey.self) { eventFrames in
                    timelineDayEventFrames = eventFrames
                }
        }
        .overlay {}
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

enum DragEvent {
    case began(location: CGPoint)
    case changed(translation: CGPoint)
    case ended
}
