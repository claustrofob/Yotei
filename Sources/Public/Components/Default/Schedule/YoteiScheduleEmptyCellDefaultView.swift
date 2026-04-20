//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleEmptyCellDefaultView: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle

    public init() {}

    public var body: some View {
        Text("No events")
            .font(fontStyle.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}
