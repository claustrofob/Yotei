//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesMonthEventDefaultView<Data: YoteiEventData>: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle

    private let event: YoteiEvent<Data>

    public init(event: YoteiEvent<Data>) {
        self.event = event
    }

    public var body: some View {
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.background)
            .font(fontStyle.caption2)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
            .background(.tint)
            .clipShape(.rect(cornerRadius: 6))
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}
