//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdayTitlesView: View {
    @Environment(\.calendar) private var calendar

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(calendar.weekdayIndices, id: \.self) { index in
                Text("\(calendar.veryShortStandaloneWeekdaySymbols[index - 1])")
                    .frame(maxWidth: .infinity)
                    .font(.system(.caption))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
