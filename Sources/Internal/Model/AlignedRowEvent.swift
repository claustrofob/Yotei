//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

enum AlignedRowEvent<Data: YoteiEventData>: Equatable, Identifiable {
    var id: String {
        switch self {
        case .event(event: let event, cols: _):
            "event_\(event.id)"
        case .extra(index: let index, count: _):
            "count_\(index)"
        case let .empty(index):
            "empty_\(index)"
        }
    }

    case event(event: YoteiEvent<Data>, cols: Int)
    case extra(index: Int, count: Int)
    case empty(index: Int)
}
