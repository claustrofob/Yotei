//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripExpandDefaultView: View {
    private let isExpanded: Bool

    public init(isExpanded: Bool) {
        self.isExpanded = isExpanded
    }

    public var body: some View {
        Image(systemName: "chevron.compact.down")
            .foregroundStyle(.primary)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .contentShape(Rectangle())
            .background(.background)
    }
}
