//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsEventDefaultView<Data: YoteiEventData>: View {
    private let event: YoteiEvent<Data>

    public init(event: YoteiEvent<Data>) {
        self.event = event
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .foregroundStyle(.background)
                .font(.system(.caption2))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 16)
                .padding(.horizontal, 4)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(.tint)
        .clipShape(.rect(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .inset(by: 0.5)
                .stroke(.background, lineWidth: 1)
        )
    }
}
