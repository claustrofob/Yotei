//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleAllDayEventCellDefaultView<Data: YoteiEventData>: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle
    @Environment(\.calendar) private var calendar

    private let nowDate = Date.now

    private let cellDate: Date
    private let event: YoteiEvent<Data>

    public init(cellDate: Date, event: YoteiEvent<Data>) {
        self.cellDate = cellDate
        self.event = event
    }

    public var body: some View {
        let isPast = event.end < nowDate || (cellDate < calendar.startOfDay(for: nowDate))
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.background)
            .font(fontStyle.caption)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                    .fill(.tint)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(isPast ? 0.5 : 1)
            }
    }
}
