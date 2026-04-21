//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public enum CalendarViewType: String, CaseIterable {
    case schedule
    case day
    case week
    case month

    var icon: Image {
        switch self {
        case .schedule: Image(.scheduleIcon)
        case .day: Image(.dayIcon)
        case .week: Image(.weekIcon)
        case .month: Image(.monthIcon)
        }
    }

    var title: String {
        switch self {
        case .schedule: "Schedule"
        case .day: "Day"
        case .week: "Week"
        case .month: "Month"
        }
    }
}
