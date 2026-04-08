//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdayTitlesView: View {
    public init() {}

    public var body: some View {
        HStack {
            ForEach(Calendar.current.weekdayIndices, id: \.self) { index in
                Text("\(Calendar.current.veryShortStandaloneWeekdaySymbols[index - 1])")
                    .frame(maxWidth: .infinity)
                    .font(.system(.caption))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
