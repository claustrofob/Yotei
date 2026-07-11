//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsEventPlaceholderDefaultView: View {
    private enum Constants {
        static var paddingCoefficient: CGFloat {
            0.033
        }
    }

    public init() {}

    public var body: some View {
        RoundedRectangle(cornerSize: .init(width: 4, height: 4))
            .stroke(.secondary, lineWidth: 2)
            .contentShape(Rectangle())
    }
}
