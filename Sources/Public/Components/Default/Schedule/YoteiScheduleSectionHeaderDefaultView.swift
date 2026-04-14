//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleSectionHeaderDefaultView: View {
    private let date: Date
    private let sectionInsets: UIEdgeInsets
    private let calendar: Calendar

    public init(
        date: Date,
        sectionInsets: UIEdgeInsets,
        calendar: Calendar
    ) {
        self.date = date
        self.sectionInsets = sectionInsets
        self.calendar = calendar
    }

    public var body: some View {
        let dateFormatStyle = Date.FormatStyle(calendar: calendar)
            .month(.wide)
            .day()
            .weekday(.wide)
        Text(date.formatted(dateFormatStyle))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, sectionInsets.left)
            .padding(.trailing, sectionInsets.right)
            .background(.background)
    }
}
