//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsTimeSlotDefaultView: View {
    private let date: Date
    private let calendar: Calendar

    public init(date: Date, calendar: Calendar) {
        self.date = date
        self.calendar = calendar
    }

    public var body: some View {
        let timeFormatStyle = Date.FormatStyle(calendar: calendar)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .locale(Locale.time24Hour)

        HStack(spacing: 6) {
            Text(date.formatted(timeFormatStyle))
                .font(.system(.caption))
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
