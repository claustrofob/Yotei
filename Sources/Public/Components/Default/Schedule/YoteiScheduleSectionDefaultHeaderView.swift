//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleSectionDefaultHeaderView: View {
    private static let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var body: some View {
        Text(date.formatted(Self.dateFormatStyle))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .background(.background)
    }
}
