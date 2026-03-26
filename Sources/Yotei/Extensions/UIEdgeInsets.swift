import Foundation
import SwiftUI

extension UIEdgeInsets {
    init(from insets: EdgeInsets) {
        self.init(
            top: insets.top,
            left: insets.leading,
            bottom: insets.bottom,
            right: insets.trailing
        )
    }
}
