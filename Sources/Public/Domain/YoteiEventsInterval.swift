//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public struct YoteiEventsInterval: Equatable {
    // full interval: [a few prev days + monthInterval + a few next days]
    public let dateInterval: DateInterval?
    public let dateLoadingInterval: DateInterval?
    // active month interval
    public let monthInterval: DateInterval?
    public let events: [Date: [YoteiEvent]]

    public init(
        dateInterval: DateInterval? = nil,
        dateLoadingInterval: DateInterval? = nil,
        monthInterval: DateInterval? = nil,
        events: [Date: [YoteiEvent]] = [:]
    ) {
        self.dateInterval = dateInterval
        self.dateLoadingInterval = dateLoadingInterval
        self.monthInterval = monthInterval
        self.events = events
    }
}
