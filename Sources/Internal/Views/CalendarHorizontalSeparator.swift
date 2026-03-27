//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct CalendarHorizontalSeparator: View {
    public init() {}

    public var body: some View {
        Color.black.opacity(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
