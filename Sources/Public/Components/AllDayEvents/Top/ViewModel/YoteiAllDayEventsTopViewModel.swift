//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

enum YoteiAllDayEventsTopViewModel<Data: YoteiEventData>: Equatable, Identifiable {
    var id: String {
        switch self {
        case .event(event: let event, cols: _):
            "event_\(event.id)"
        case let .empty(index):
            "empty_\(index)"
        }
    }

    case event(event: YoteiEvent<Data>, cols: Int)
    case empty(index: Int)
}
