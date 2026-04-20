//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleSectionHeaderDefaultView: View {
    @Environment(\.yoteiFontStyle) var fontStyle: YoteiFontStyle
    @Environment(\.calendar) private var calendar

    private let date: Date
    private let sectionInsets: UIEdgeInsets

    public init(date: Date, sectionInsets: UIEdgeInsets) {
        self.date = date
        self.sectionInsets = sectionInsets
    }

    public var body: some View {
        let dateFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone)
            .month(.wide)
            .day()
            .weekday(.wide)
        Text(date.formatted(dateFormatStyle))
            .font(calendar.isDateInToday(date) ? fontStyle.headline : fontStyle.subheadline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, sectionInsets.left)
            .padding(.trailing, sectionInsets.right)
            .background(.background)
    }
}
