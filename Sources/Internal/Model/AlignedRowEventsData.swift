//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct AlignedRowEventsData<Data: YoteiEventData> {
    let startDate: Date
    let events: [[AlignedRowEvent<Data>]]
    let extraCount: [Date: Int]

    init(startDate: Date, events: [[AlignedRowEvent<Data>]] = [], extraCount: [Date: Int] = [:]) {
        self.startDate = startDate
        self.events = events
        self.extraCount = extraCount
    }
}
