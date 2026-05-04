//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import UIKit

final class DisplayLink {
    private var displayLink: CADisplayLink?
    private var onStep: (() -> Void)?

    init(onStep: @escaping () -> Void) {
        self.onStep = onStep
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.add(to: .current, forMode: RunLoop.Mode.common)
    }

    func invalidate() {
        onStep = nil
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func step() {
        onStep?()
    }
}
