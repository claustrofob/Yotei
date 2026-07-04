//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct ParentViewRepresentable<ViewType: UIView>: UIViewRepresentable {
    final class ParentViewFinderView: UIView {
        private let completion: (ViewType) -> Void

        init(completion: @escaping (ViewType) -> Void) {
            self.completion = completion
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else {
                return
            }
            var targetView = superview
            while !(targetView is ViewType), targetView != nil {
                targetView = targetView?.superview
            }
            guard let targetView = targetView as? ViewType else {
                return
            }

            completion(targetView)
        }
    }

    let completion: (ViewType) -> Void

    func makeUIView(context _: Context) -> ParentViewFinderView {
        ParentViewFinderView(completion: completion)
    }

    func updateUIView(_: ParentViewFinderView, context _: Context) {}
}
