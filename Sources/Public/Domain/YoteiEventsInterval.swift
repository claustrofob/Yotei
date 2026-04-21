//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public struct YoteiEventsInterval<Data: YoteiEventData>: Equatable, Sendable {
    // active month interval
    public var monthInterval: DateInterval?
    // full interval: [a few prev days + monthInterval + a few next days]
    public var dateInterval: DateInterval?
    // interval that is currently loading and for which to display preloader
    public var dateLoadingInterval: DateInterval?
    public var events: [Date: [YoteiEvent<Data>]]

    public init(
        monthInterval: DateInterval? = nil,
        dateInterval: DateInterval? = nil,
        dateLoadingInterval: DateInterval? = nil,
        events: [Date: [YoteiEvent<Data>]] = [:]
    ) {
        self.monthInterval = monthInterval
        self.dateInterval = dateInterval
        self.dateLoadingInterval = dateLoadingInterval
        self.events = events
    }
}
