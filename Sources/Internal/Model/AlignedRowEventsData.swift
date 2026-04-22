//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct AlignedRowEventsData<Data: YoteiEventData> {
    let startDate: Date
    let events: [[AlignedRowEvent<Data>]]

    init(startDate: Date, events: [[AlignedRowEvent<Data>]] = []) {
        self.startDate = startDate
        self.events = events
    }
}
