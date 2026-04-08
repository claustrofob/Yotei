//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

public struct DayEventsViewFactory: YoteiDayEventsViewFactoryProtocol {
    public init() {}

    public func eventView(event: YoteiEvent) -> some View {
        YoteiDayEventsViewFactory().eventView(event: event)
            .tint(.blue)
            .foregroundStyle(.white, .white)
    }
}
