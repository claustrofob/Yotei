//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleEventCellDefaultView: View {
    private let nowDate = Date.now

    private var dateRange: Range<Date> {
        event.dateInterval.start ..< event.dateInterval.end
    }

    private let timeIntervalShortFormatStyle = Date.IntervalFormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute()

    private let timeIntervalLongFormatStyle = Date.IntervalFormatStyle()
        .day()
        .month(.abbreviated)
        .hour(.twoDigits(amPM: .omitted))
        .minute()

    private let cellDate: Date
    private let event: YoteiEvent

    public init(cellDate: Date, event: YoteiEvent) {
        self.cellDate = cellDate
        self.event = event
    }

    public var body: some View {
        let isPast = event.end < nowDate || (cellDate < Calendar.current.startOfDay(for: nowDate))
        let dateInterval = event.dateInterval

        VStack(alignment: .leading, spacing: 4) {
            let dateStyle = dateInterval.start.isInSameDay(as: dateInterval.end)
                ? timeIntervalShortFormatStyle
                : timeIntervalLongFormatStyle
            Text(dateRange.formatted(dateStyle))
                .font(.system(.caption2))
            Text(event.title)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.system(.subheadline))
        }
        .foregroundStyle(.background)
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(.tint)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isPast ? 0.5 : 1)
        }
    }
}
