//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public enum CalendarViewType: String, CaseIterable {
    case schedule
    case day
    case week

    var icon: Image {
        switch self {
        case .schedule: Image(systemName: "inset.filled.topthird.middlethird.bottomthird.rectangle")
        case .day: Image(systemName: "calendar.day.timeline.left")
        case .week: Image(systemName: "inset.filled.leftthird.middlethird.rightthird.rectangle")
        }
    }

    var title: String {
        switch self {
        case .schedule: "Schedule"
        case .day: "Day"
        case .week: "Week"
        }
    }
}
