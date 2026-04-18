//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct DayEventsTimeSlotView: View {
    @Environment(\.calendar) private var calendar

    private let date: Date

    init(date: Date) {
        self.date = date
    }

    var body: some View {
        let timeFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone)
            .hour(.defaultDigits(amPM: .abbreviated))
            .locale(Locale(identifier: "en_US_POSIX"))

        HStack(spacing: 6) {
            Text(date.formatted(timeFormatStyle))
                .font(.system(.caption))
                .fixedSize()
                .frame(width: 32, alignment: .trailing)
                .foregroundStyle(.secondary)

            LineView()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .foregroundStyle(.quaternary)
        }
    }
}

private struct LineView: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}
