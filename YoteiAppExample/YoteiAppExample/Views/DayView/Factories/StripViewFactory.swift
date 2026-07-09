//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct StripViewFactory: YoteiStripViewFactoryProtocol {
    func expandView(progress: CGFloat) -> some View {
        YoteiStripViewFactory().expandView(progress: progress)
            .foregroundStyle(.purple)
    }
}
