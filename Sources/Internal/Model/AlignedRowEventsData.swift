//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct AlignedRowEventsData<Data: YoteiEventData> {
    let events: [[AlignedRowEvent<Data>]]
    let extraCount: [Date: Int]

    init(events: [[AlignedRowEvent<Data>]] = [], extraCount: [Date: Int] = [:]) {
        self.events = events
        self.extraCount = extraCount
    }
}
