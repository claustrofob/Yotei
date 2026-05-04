//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

extension YoteiDragEventView {
    struct ContainerView: UIViewControllerRepresentable {
        @Binding private var data: YoteiEventsInterval<Data>
        @Binding private var contentOffset: CGPoint?
        @Binding private var focusedDate: Date
        @ViewBuilder private let content: () -> Content
        private let viewFactory: ViewFactory

        @State var dragEvent: DragEvent = .ended

        private var internalView: OverlayView {
            OverlayView(
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

        func makeUIViewController(context: Context) -> UIHostingController<OverlayView> {
            let vc = UIHostingController(rootView: internalView)
            vc.view.addGestureRecognizer(context.coordinator.pressGesture)
            vc.view.addGestureRecognizer(context.coordinator.panGesture)
            return vc
        }

        func updateUIViewController(_ uiViewController: UIHostingController<OverlayView>, context _: Context) {
            uiViewController.rootView = internalView
        }
    }
}

extension YoteiDragEventView.ContainerView {
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
