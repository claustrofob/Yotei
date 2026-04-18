//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct YoteiScheduleViewModel<Data: YoteiEventData>: Identifiable, Equatable {
    enum Kind: Equatable {
        case event(YoteiEvent<Data>)
        case empty
        case loading
    }

    let date: Date
    let kind: Kind

    var id: String {
        switch kind {
        case let .event(item):
            "event_\(date.timeIntervalSince1970)_\(item.id)"
        case .empty:
            "empty_\(date.timeIntervalSince1970)"
        case .loading:
            "loading_\(date.timeIntervalSince1970)"
        }
    }
}
