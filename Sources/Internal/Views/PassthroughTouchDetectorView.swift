//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

public struct PassthroughTouchDetectorView: UIViewRepresentable {
    private final class PassthroughView: UIView {
        private let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
            onTap()
            return nil
        }
    }

    private let onTap: () -> Void

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public func makeUIView(context _: Context) -> UIView {
        PassthroughView(onTap: onTap)
    }

    public func updateUIView(_: UIView, context _: Context) {}
}
