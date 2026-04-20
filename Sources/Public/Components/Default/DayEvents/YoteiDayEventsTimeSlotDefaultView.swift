//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsTimeSlotDefaultView: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle
    @Environment(\.calendar) private var calendar

    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var body: some View {
        let timeFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .locale(Locale.time24Hour)

        HStack(spacing: 6) {
            Text(date.formatted(timeFormatStyle))
                .font(fontStyle.caption)
                .fixedSize()
                .frame(width: 32, alignment: .trailing)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(.quaternary)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
    }
}
