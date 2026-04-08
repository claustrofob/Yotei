//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsDaysDelimiterDefaultView: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(.tertiary)
            .frame(width: 1)
            .frame(maxHeight: .infinity)
    }
}
