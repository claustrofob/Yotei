//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct CalendarDayCellView: View {
    private typealias CellStyle = (
        backgroundColor: Color,
        foregroundColor: Color,
        isEventsVisible: Bool
    )

    private let dayFormatStyle: Date.FormatStyle
    private let date: Date
    private let todayDate: Date
    private let focusedDate: Date?
    private let isEnabled: Bool
    private let calendar: Calendar

    init(
        date: Date,
        todayDate: Date,
        focusedDate: Date? = nil,
        isEnabled: Bool = true,
        calendar: Calendar = .current
    ) {
        self.date = date
        self.todayDate = todayDate
        self.focusedDate = focusedDate
        self.isEnabled = isEnabled
        self.calendar = calendar
        dayFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day()
    }

    var body: some View {
        let style = dayStyle(date: date)
        Text(date.formatted(dayFormatStyle))
            .font(.system(.subheadline))
            .foregroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: 40)
            .background {
                Circle().fill(style.backgroundColor)
            }
    }

    private func dayStyle(date: Date) -> CellStyle {
        if date.isInSameDay(as: todayDate) {
            (Color.blue, .white, false)
        } else if !isEnabled {
            (.clear, .secondary, false)
        } else if let focusedDate, date.isInSameDay(as: focusedDate) {
            (Color.blue.opacity(0.2), .blue, false)
        } else {
            (.clear, .primary, true)
        }
    }
}
