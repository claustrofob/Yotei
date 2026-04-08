//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsCurrentTimeMarkerDefaultView: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.primary)
                .frame(height: 1)
            Circle()
                .fill(.primary)
                .frame(width: 8, height: 8)
                .offset(x: -4)
        }
    }
}
