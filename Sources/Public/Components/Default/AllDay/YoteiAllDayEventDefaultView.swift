//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiAllDayEventDefaultView<Data: YoteiEventData>: View {
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
            .font(fontStyle.caption)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
            .background(.tint)
            .clipShape(.rect(cornerRadius: 6))
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}
