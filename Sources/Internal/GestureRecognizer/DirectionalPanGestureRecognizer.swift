//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

final class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {
    private let activationThreshold: CGFloat = 8
    private let onDrag: (DragEvent) -> Void

    init(onDrag: @escaping (DragEvent) -> Void) {
        self.onDrag = onDrag
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handle))
    }

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

    @objc
    private func handle() {
        switch state {
        case .began:
            let location = location(in: view)
            onDrag(.began(location: location))
        case .changed:
            let translation = translation(in: view)
            let location = location(in: view)
            let velocity = velocity(in: view)
            onDrag(.changed(translation: translation, location: location, velocity: velocity))
        case .ended, .cancelled:
            onDrag(.ended)
        default:
            break
        }
    }
}
