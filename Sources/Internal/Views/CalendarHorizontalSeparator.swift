//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct CalendarHorizontalSeparator: View {
    init() {}

    var body: some View {
        Color.black.opacity(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
