//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiMonthSelectorButtonDefaultView: View {
    private let date: Date
    private let isExpanded: Bool
    private let calendar: Calendar

    public init(
        date: Date,
        isExpanded: Bool,
        calendar: Calendar
    ) {
        self.date = date
        self.isExpanded = isExpanded
        self.calendar = calendar
    }

    public var body: some View {
        let monthYearFormatStyle = Date.FormatStyle(calendar: calendar)
            .month(.wide)
            .year(.defaultDigits)

        HStack(spacing: 16) {
            Text(date.formatted(monthYearFormatStyle).capitalizedFirstLetter)
                .font(.system(.body))
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
    }
}
