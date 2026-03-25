import SwiftUI
import UIKit

struct PassthroughTouchDetectorView: UIViewRepresentable {
    private final class PassthroughView: UIView {
        private let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            onTap()
            return nil
        }
    }

    private let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    func makeUIView(context: Context) -> UIView {
        PassthroughView(onTap: onTap)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
