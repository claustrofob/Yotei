//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesMonthDayCellDefaultView: View {
    private typealias CellStyle = (
        backgroundColor: AnyShapeStyle,
        foregroundColor: AnyShapeStyle
    )

    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle
    @Environment(\.calendar) private var calendar

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
        let dayFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day()
        Text(date.formatted(dayFormatStyle))
            .font(fontStyle.caption2)
            .foregroundStyle(style.foregroundColor)
            .padding(4)
            .background {
                Circle().fill(style.backgroundColor)
            }
            .padding(2)
    }

    private func dayStyle(date: Date) -> CellStyle {
        if date.isInSameDay(as: todayDate, in: calendar) {
            (AnyShapeStyle(.tint), AnyShapeStyle(.background))
        } else if !isEnabled {
            (AnyShapeStyle(.clear), AnyShapeStyle(.tertiary))
        } else if let focusedDate, date.isInSameDay(as: focusedDate, in: calendar) {
            (AnyShapeStyle(.tint.opacity(0.2)), AnyShapeStyle(.secondary))
        } else {
            (AnyShapeStyle(.clear), AnyShapeStyle(.primary))
        }
    }
}
