import SwiftUI
import UIKit

struct ScrollViewPositionModifier: ViewModifier {
    @Binding var contentOffset: CGPoint
    @State private var lastContentOffset: CGPoint?
    @State private var scrollView: UIScrollView?
    @State private var observation: NSKeyValueObservation?

    func body(content: Content) -> some View {
        content
            .parentView { (scrollView: UIScrollView) in
                guard self.scrollView !== scrollView else {
                    return
                }
                self.scrollView = scrollView
                // This callback maybe called several times for the view with detached State variables.
                // So even if i set `self.scrollView` it will remain `nil`.
                // To reproduce: in calendar in "Day" view tap on a different date in calendar strip.
                // This callback is fired 6 times for the previous date view with detached state.
                guard self.scrollView != nil else {
                    return
                }
                // during initialization `.onChange` is called first with the proper value of `contentOffset`,
                // then `.parentView` is called with an old value of `contentOffset`. This is weird.
                // To fix it we set `lastContentOffset = contentOffset` in `.onChange` and
                // in `.parentView` is has the proper value.
                scrollView.contentOffset = lastContentOffset ?? contentOffset
                observation = scrollView.observe(\.contentOffset, options: [.new, .initial]) { _, change in
                    // KVO can fire during SwiftUI layout updates
                    // Push the binding update to the next runloop tick
                    DispatchQueue.main.async {
                        contentOffset = change.newValue ?? .zero
                        lastContentOffset = contentOffset
                    }
                }
            }
            .onChange(of: contentOffset) { _ in
                guard lastContentOffset != contentOffset else {
                    return
                }
                DispatchQueue.main.async {
                    lastContentOffset = contentOffset
                    scrollView?.contentOffset = contentOffset
                }
            }
    }
}

extension View {
    func scrollViewPosition(_ contentOffset: Binding<CGPoint>) -> some View {
        modifier(ScrollViewPositionModifier(contentOffset: contentOffset))
    }
}
