//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDragEventView<ViewFactory: YoteiDragEventViewFactoryProtocol, Content: View, Data: YoteiEventData>: UIViewControllerRepresentable {
    public typealias InternalViewType = DragEventViewInternal<ViewFactory, Content, Data>

    @Binding private var data: YoteiEventsInterval<Data>
    @ViewBuilder private let content: () -> Content
    private let viewFactory: ViewFactory

    @State var dragEvent: DragEvent = .ended

    private var internalView: InternalViewType {
        DragEventViewInternal(
            data: $data,
            dragEvent: $dragEvent,
            viewFactory: viewFactory,
            content: content
        )
    }

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        self.viewFactory = viewFactory
        self.content = content
    }

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        @ViewBuilder content: @escaping () -> Content
    ) where ViewFactory == YoteiDragEventViewFactory<Data> {
        self.init(
            data: data,
            viewFactory: YoteiDragEventViewFactory(),
            content: content
        )
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(dragEvent: $dragEvent)
    }

    public func makeUIViewController(context: Context) -> UIHostingController<InternalViewType> {
        let vc = UIHostingController(rootView: internalView)
        vc.view.addGestureRecognizer(context.coordinator.pressGesture)
        vc.view.addGestureRecognizer(context.coordinator.panGesture)
        return vc
    }

    public func updateUIViewController(_ uiViewController: UIHostingController<InternalViewType>, context _: Context) {
        uiViewController.rootView = internalView
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

public struct DragEventViewInternal<ViewFactory: YoteiDragEventViewFactoryProtocol, Content: View, Data: YoteiEventData>: View {
    @Binding private var data: YoteiEventsInterval<Data>
    @Binding private var dragEvent: DragEvent
    private let viewFactory: ViewFactory
    @ViewBuilder private let content: () -> Content

    @State private var timelineDayFrames = [Date: CGRect]()
    @State private var timelineDayEventFrames = [Date: [EventFrame]]()

    @State private var activeDate: Date?
    @State private var activeEvent: YoteiEvent<Data>?

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        dragEvent: Binding<DragEvent>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        _dragEvent = dragEvent
        self.viewFactory = viewFactory
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            content()
                .onPreferenceChange(DayTimelineAnchorKey.self) { timelineAnchors in
                    timelineDayFrames = timelineAnchors.mapValues { proxy[$0] }
                }
                .onPreferenceChange(EventTimelineFramesKey.self) { eventFrames in
                    timelineDayEventFrames = eventFrames
                }
        }
        .onChange(of: dragEvent) { _ in
            switch dragEvent {
            case let .began(location):
                guard let date = findActiveDate(under: location) else {
                    return
                }
                activeDate = date
                activeEvent = findActiveEvent(date: date, under: location) // TODO: or create a placeholder event
            case let .changed(translation):
                print("changed \(translation)")
            case .ended:
                print("ended")
            }
        }
        .overlay {}
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

public enum DragEvent: Equatable {
    case began(location: CGPoint)
    case changed(translation: CGPoint)
    case ended
}
