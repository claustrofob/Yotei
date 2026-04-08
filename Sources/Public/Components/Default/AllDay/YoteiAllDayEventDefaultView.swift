//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiAllDayEventDefaultView: View {
    private let event: YoteiEvent

    public init(event: YoteiEvent) {
        self.event = event
    }

    public var body: some View {
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.primary)
            .font(.system(.caption2))
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
            .background(.tint)
            .clipShape(.rect(cornerRadius: 6))
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}
