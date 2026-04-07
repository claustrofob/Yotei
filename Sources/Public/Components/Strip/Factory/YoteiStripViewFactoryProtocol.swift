//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiStripViewFactoryProtocol {
    associatedtype ExpandView: View
    func expandView(isExpanded: Bool) -> ExpandView

    func weekInteritemVerticalSpacing() -> CGFloat
}

public extension YoteiStripViewFactoryProtocol {
    func expandView(isExpanded: Bool) -> some View {
        YoteiStripExpandDefaultView(isExpanded: isExpanded)
    }

    func weekInteritemVerticalSpacing() -> CGFloat {
        8
    }
}
