//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleSectionHeaderDefaultView: View {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    private let date: Date
    private let sectionInsets: UIEdgeInsets

    public init(date: Date, sectionInsets: UIEdgeInsets) {
        self.date = date
        self.sectionInsets = sectionInsets
    }

    public var body: some View {
        Text(date.formatted(dateFormatStyle))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, sectionInsets.left)
            .padding(.trailing, sectionInsets.right)
            .background(.background)
    }
}
