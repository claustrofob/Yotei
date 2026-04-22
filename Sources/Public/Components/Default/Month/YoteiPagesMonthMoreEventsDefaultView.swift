//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesMonthMoreEventsDefaultView: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle

    private let moreEventsCount: Int

    public init(moreEventsCount: Int) {
        self.moreEventsCount = moreEventsCount
    }

    public var body: some View {
        Text("+\(moreEventsCount)")
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .font(fontStyle.caption2)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 14)
            .frame(maxWidth: .infinity)
            .clipped()
            .background(.tertiary)
            .clipShape(.rect(cornerRadius: 6))
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}
