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

    private static let timeIntervalShortFormatStyle = Date.IntervalFormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute()

    private static let timeIntervalLongFormatStyle = Date.IntervalFormatStyle()
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
        Group {
            if event.isAllDay {
                allDayEventView()
            } else {
                eventView()
            }
        }
        .opacity(isPast ? 0.5 : 1)
    }

    @ViewBuilder
    private func eventView() -> some View {
        let dateInterval = event.dateInterval
        let isNow = cellDate.isInSameDay(as: nowDate) && dateInterval.contains(nowDate)

        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                if isNow {
                    HStack(alignment: .center, spacing: 4) {
                        Circle()
                            .frame(width: 6, height: 6)
                        Text("Now")
                            .font(.system(.caption))
                    }
                    .foregroundStyle(.purple)
                }

                let dateStyle = dateInterval.start.isInSameDay(as: dateInterval.end)
                    ? Self.timeIntervalShortFormatStyle
                    : Self.timeIntervalLongFormatStyle
                Text(dateRange.formatted(dateStyle))
                    .font(.system(.caption2))
                    .foregroundStyle(.blue.opacity(0.5))
            }
            eventTitle()
                .font(.system(.subheadline))
        }
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(.blue.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func allDayEventView() -> some View {
        eventTitle()
            .font(.system(.caption2))
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(.blue.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
    }

    private func eventTitle() -> some View {
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.blue.opacity(0.5))
    }
}
