//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayCellDefaultView: View {
    private typealias CellStyle = (
        backgroundColor: Color,
        foregroundColor: Color,
        isEventsVisible: Bool
    )

    private let date: Date
    private let todayDate: Date
    private let focusedDate: Date?
    private let isEnabled: Bool

    public init(
        date: Date,
        todayDate: Date,
        focusedDate: Date? = nil,
        isEnabled: Bool = true
    ) {
        self.date = date
        self.todayDate = todayDate
        self.focusedDate = focusedDate
        self.isEnabled = isEnabled
    }

    public var body: some View {
        let style = dayStyle(date: date)
        let dayFormatStyle = Date.FormatStyle(calendar: Calendar.current, timeZone: Calendar.current.timeZone).day()
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
