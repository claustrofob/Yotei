//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiMonthSelectorButtonDefaultView: View {
    @Environment(\.calendar) private var calendar

    private let date: Date
    private let isExpanded: Bool

    public init(
        date: Date,
        isExpanded: Bool
    ) {
        self.date = date
        self.isExpanded = isExpanded
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
