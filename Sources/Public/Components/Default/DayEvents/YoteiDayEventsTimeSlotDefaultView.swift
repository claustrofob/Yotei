//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsTimeSlotDefaultView: View {
    private static let timeFormatStyle = Date.FormatStyle()
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
        .locale(Locale.time24Hour)

    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var body: some View {
        HStack(spacing: 6) {
            Text(date.formatted(Self.timeFormatStyle))
                .font(.system(.caption))
                .fixedSize()
                .frame(width: 32, alignment: .trailing)
            Color.secondary.opacity(0.5)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
    }
}
