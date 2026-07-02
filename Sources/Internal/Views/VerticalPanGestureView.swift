//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct VerticalPanGestureView<Content: View>: UIViewControllerRepresentable {
    @ViewBuilder private let content: () -> Content

    @State var dragEvent: DragEvent = .ended

    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let vc = UIHostingController(rootView: content())
        vc.view.addGestureRecognizer(context.coordinator.panGesture)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context _: Context) {
        uiViewController.rootView = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dragEvent: $dragEvent)
    }
}

extension VerticalPanGestureView {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        lazy var panGesture: UIPanGestureRecognizer = {
            let gesture = DirectionalPanGestureRecognizer(target: self, action: #selector(handle(_:)))
            gesture.delegate = self
            return gesture
        }()

        @Binding private var dragEvent: DragEvent

        init(dragEvent: Binding<DragEvent>) {
            _dragEvent = dragEvent
            super.init()
        }

        @objc
        func handle(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                let location = gesture.location(in: gesture.view)
                dragEvent = .began(location: location)
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                let location = gesture.location(in: gesture.view)
                dragEvent = .changed(translation: translation, location: location)
            case .ended, .cancelled:
                dragEvent = .ended
            default:
                break
            }
        }
    }
}

private final class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {
    private let activationThreshold: CGFloat = 5

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard state == .possible else {
            return
        }
        let translation = translation(in: view)
        let absX = abs(translation.x)
        let absY = abs(translation.y)
        guard max(absX, absY) >= activationThreshold else {
            return
        }
        if absX > absY {
            state = .failed
        } else {
            state = .began
        }
    }
}
