//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripExpandDefaultView: View {
    private let progress: CGFloat

    public init(progress: CGFloat) {
        self.progress = progress
    }

    public var body: some View {
        Image(systemName: "chevron.compact.down")
            .foregroundStyle(.primary)
            .rotationEffect(.degrees(180 * progress))
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .contentShape(Rectangle())
            .background(.background)
    }
}
