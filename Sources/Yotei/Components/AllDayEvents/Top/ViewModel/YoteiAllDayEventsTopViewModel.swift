//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

enum YoteiAllDayEventsTopViewModel: Equatable, Identifiable {
    var id: String {
        switch self {
        case .event(event: let event, cols: _):
            "event_\(event.id)"
        case let .empty(index):
            "empty_\(index)"
        }
    }

    case event(event: YoteiEvent, cols: Int)
    case empty(index: Int)
}
