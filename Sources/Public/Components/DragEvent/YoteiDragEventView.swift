//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDragEventView<ViewFactory: YoteiDragEventViewFactoryProtocol, Content: View, Data: YoteiEventData>: View where ViewFactory.Data == Data {
    @Binding private var data: YoteiEventsInterval<Data>
    @Binding private var contentOffset: CGPoint?
    @Binding private var focusedDate: Date
    @ViewBuilder private let content: () -> Content
    private let viewFactory: ViewFactory

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        _contentOffset = contentOffset
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
        self.content = content
    }

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        @ViewBuilder content: @escaping () -> Content
    ) where ViewFactory == YoteiDragEventViewFactory<Data> {
        self.init(
            data: data,
            contentOffset: contentOffset,
            focusedDate: focusedDate,
            viewFactory: YoteiDragEventViewFactory(),
            content: content
        )
    }

    public var body: some View {
        DragEventViewContainer(
            data: $data,
            contentOffset: $contentOffset,
            focusedDate: $focusedDate,
            viewFactory: viewFactory,
            content: content
        )
        .ignoresSafeArea()
    }
}

struct DragEventViewContainer<ViewFactory: YoteiDragEventViewFactoryProtocol, Content: View, Data: YoteiEventData>: UIViewControllerRepresentable where ViewFactory.Data == Data {
    typealias InternalViewType = DragEventViewInternal<ViewFactory, Content, Data>

    @Binding private var data: YoteiEventsInterval<Data>
    @Binding private var contentOffset: CGPoint?
    @Binding private var focusedDate: Date
    @ViewBuilder private let content: () -> Content
    private let viewFactory: ViewFactory

    @State var dragEvent: DragEvent = .ended

    private var internalView: InternalViewType {
        DragEventViewInternal(
            data: $data,
            contentOffset: $contentOffset,
            focusedDate: $focusedDate,
            dragEvent: $dragEvent,
            viewFactory: viewFactory,
            content: content
        )
    }

    init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        _contentOffset = contentOffset
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
        self.content = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dragEvent: $dragEvent)
    }

    func makeUIViewController(context: Context) -> UIHostingController<InternalViewType> {
        let vc = UIHostingController(rootView: internalView)
        vc.view.addGestureRecognizer(context.coordinator.pressGesture)
        vc.view.addGestureRecognizer(context.coordinator.panGesture)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIHostingController<InternalViewType>, context _: Context) {
        uiViewController.rootView = internalView
    }
}

extension DragEventViewContainer {
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
                dragEvent = .ended
            default:
                break
            }
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                let location = gesture.location(in: gesture.view)
                dragEvent = .changed(translation: translation, location: location)
            case .ended, .cancelled:
                break
            default:
                break
            }
        }

        // MARK: - UIGestureRecognizerDelegate

        func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
            if gesture === panGesture { return isLongPressActive }
            return true
        }

        func gestureRecognizer(
            _ gesture: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            (gesture === pressGesture && other === panGesture) || (gesture === panGesture && other === pressGesture)
        }
    }
}

struct DragEventViewInternal<ViewFactory: YoteiDragEventViewFactoryProtocol, Content: View, Data: YoteiEventData>: View where ViewFactory.Data == Data {
    @Binding private var data: YoteiEventsInterval<Data>
    @Binding private var contentOffset: CGPoint?
    @Binding private var focusedDate: Date
    @Binding private var dragEvent: DragEvent
    private let viewFactory: ViewFactory
    @ViewBuilder private let content: () -> Content

    @State private var timelineDayFrames = [Date: CGRect]()
    @State private var timelineDayEventFrames = [Date: [EventFrame]]()

    @State private var activeDate: Date?
    @State private var activeEvent: YoteiEvent<Data>?
    @State private var translation: CGPoint = .zero
    @State private var hapticFeedbackGenerator = UISelectionFeedbackGenerator()

    @State private var viewHeight: CGFloat = 0
    @State private var scrollSize: CGSize = .zero
    @State private var autoScrollOffset: CGFloat = 0
    @State private var autoScrollVelocity: CGFloat = 0
    @State private var displayLink: DisplayLink?

    private let autoScrollEdgeThreshold: CGFloat = 80
    private let maxAutoScrollVelocity: CGFloat = 8

    private var totalContentHeight: CGFloat {
        24 * viewFactory.hourSlotHeight()
    }

    init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        dragEvent: Binding<DragEvent>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        _contentOffset = contentOffset
        _focusedDate = focusedDate
        _dragEvent = dragEvent
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
        }
        .onChange(of: dragEvent) { _ in
            switch dragEvent {
            case let .began(location):
                guard let date = findActiveDate(under: location) else {
                    return
                }
                activeDate = date
                activeEvent = findActiveEvent(date: date, under: location) // TODO: or create a placeholder event
                hapticFeedbackGenerator.selectionChanged()
                autoScrollOffset = 0
            case let .changed(translation, location):
                self.translation = translation
                if activeEvent != nil {
                    updateAutoScroll(fingerY: location.y)
                }
            case .ended:
                translation = .zero
                activeDate = nil
                activeEvent = nil
                autoScrollOffset = 0
                stopAutoScroll()
            }
        }
        .onGeometryChange(for: CGFloat.self) {
            $0.size.height
        } action: { newValue in
            viewHeight = newValue
        }
        .overlay(alignment: .topLeading) {
            if
                let activeEvent,
                let activeDate,
                let frame = eventFrame(event: activeEvent, startOfDay: activeDate)
            {
                viewFactory.eventView(event: activeEvent)
                    .frame(width: frame.width, height: frame.height)
                    .offset(
                        x: frame.origin.x + translation.x,
                        y: frame.origin.y + translation.y + autoScrollOffset
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
        guard viewHeight > 0 else { return }
        let topThreshold = autoScrollEdgeThreshold
        let bottomThreshold = viewHeight - autoScrollEdgeThreshold
        let velocity: CGFloat
        if fingerY < topThreshold {
            let proximity = min(1, max(0, (topThreshold - fingerY) / autoScrollEdgeThreshold))
            velocity = -maxAutoScrollVelocity * proximity
        } else if fingerY > bottomThreshold {
            let proximity = min(1, max(0, (fingerY - bottomThreshold) / autoScrollEdgeThreshold))
            velocity = maxAutoScrollVelocity * proximity
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
            autoScrollOffset += actualDelta
        }
    }

    private func stopAutoScroll() {
        autoScrollVelocity = 0
        displayLink?.invalidate()
        displayLink = nil
    }

    private func eventFrame(event: YoteiEvent<Data>, startOfDay: Date) -> CGRect? {
        guard let dateFrame = timelineDayFrames[startOfDay] else {
            return nil
        }

        let pointsPerSecond = viewFactory.hourSlotHeight() / 3600
        let originY = CGFloat(event.start.timeIntervalSince(startOfDay)) * pointsPerSecond
        let height = event.dateInterval.duration * pointsPerSecond
        return CGRect(
            x: dateFrame.minX,
            y: dateFrame.minY + originY,
            width: dateFrame.width,
            height: height
        )
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

struct EventScrollViewSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// ----------------

struct EventFrame: Equatable, Sendable {
    let id: String
    let date: Date
    let frame: CGRect
}

// -----------------

enum DragEvent: Equatable {
    case began(location: CGPoint)
    case changed(translation: CGPoint, location: CGPoint)
    case ended
}
