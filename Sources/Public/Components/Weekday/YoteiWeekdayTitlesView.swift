//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdayTitlesView: View {
    private let spacing: CGFloat

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Calendar.current.weekdayIndices, id: \.self) { index in
                Text("\(Calendar.current.veryShortStandaloneWeekdaySymbols[index - 1])")
                    .frame(maxWidth: .infinity)
                    .font(.system(.caption))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(height: 24)
    }
}
