//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayCellDefaultView: View {
    private typealias CellStyle = (
        backgroundColor: AnyShapeStyle,
        foregroundColor: AnyShapeStyle,
        isEventsVisible: Bool
    )

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
        let dayFormatStyle = Date.FormatStyle(calendar: calendar).day()
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
        if date.isInSameDay(as: todayDate, in: calendar) {
            (AnyShapeStyle(.tint), AnyShapeStyle(.background), false)
        } else if !isEnabled {
            (AnyShapeStyle(.clear), AnyShapeStyle(.tertiary), false)
        } else if let focusedDate, date.isInSameDay(as: focusedDate, in: calendar) {
            (AnyShapeStyle(.tint.opacity(0.2)), AnyShapeStyle(.secondary), false)
        } else {
            (AnyShapeStyle(.clear), AnyShapeStyle(.primary), true)
        }
    }
}
