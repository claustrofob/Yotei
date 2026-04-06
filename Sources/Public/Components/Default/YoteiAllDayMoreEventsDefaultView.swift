//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiAllDayMoreEventsDefaultView: View {
    private let moreEventsCount: Int

    public init(moreEventsCount: Int) {
        self.moreEventsCount = moreEventsCount
    }

    public var body: some View {
        Text("+\(moreEventsCount)")
            .lineLimit(1)
            .foregroundStyle(.primary.opacity(0.8))
            .font(.system(.caption2))
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(.background.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}
