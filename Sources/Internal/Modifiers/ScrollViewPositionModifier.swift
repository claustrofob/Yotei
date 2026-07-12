//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct ScrollViewPositionModifier: ViewModifier {
    private final class ScrollViewWeakStrorage: ObservableObject {
        weak var scrollView: UIScrollView?
    }

    @Binding var contentOffset: CGPoint?
    @State private var lastContentOffset: CGPoint?
    @StateObject private var scrollViewStorage = ScrollViewWeakStrorage()
    @State private var observation: NSKeyValueObservation?

    func body(content: Content) -> some View {
        content
            .parentView { (scrollView: UIScrollView) in
                guard scrollViewStorage.scrollView !== scrollView else {
                    return
                }
                scrollViewStorage.scrollView = scrollView
                // This callback maybe called several times for the view with detached State variables.
                // So even if i set `self.scrollView` it will remain `nil`.
                // To reproduce: in calendar in "Day" view tap on a different date in calendar strip.
                // This callback is fired 6 times for the previous date view with detached state.
                guard scrollViewStorage.scrollView != nil else {
                    return
                }

                scrollView.contentOffset = contentOffset ?? .zero
                observation = scrollView.observe(\.contentOffset, options: [.new, .initial]) { _, change in
                    // KVO can fire during SwiftUI layout updates
                    // Push the binding update to the next runloop tick
                    DispatchQueue.main.async {
                        let newContentOffset = change.newValue ?? .zero
                        guard lastContentOffset != newContentOffset else {
                            return
                        }
                        lastContentOffset = newContentOffset
                        contentOffset = newContentOffset
                    }
                }
            }
            .onChange(of: contentOffset, initial: false) { contentOffset in
                guard lastContentOffset != contentOffset else {
                    return
                }

                lastContentOffset = contentOffset
                scrollViewStorage.scrollView?.contentOffset = contentOffset ?? .zero
            }
    }
}

extension View {
    func scrollViewPosition(_ contentOffset: Binding<CGPoint?>) -> some View {
        modifier(ScrollViewPositionModifier(contentOffset: contentOffset))
    }
}
