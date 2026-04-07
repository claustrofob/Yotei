//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDayEventsCurrentTimeMarkerDefaultView: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            Color.blue
                .frame(height: 1)
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
                .offset(x: -4)
        }
    }
}
