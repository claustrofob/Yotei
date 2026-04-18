//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct StripViewFactory: YoteiStripViewFactoryProtocol {
    func expandView(isExpanded: Bool) -> some View {
        YoteiStripViewFactory().expandView(isExpanded: isExpanded)
            .foregroundStyle(.purple)
    }
}
