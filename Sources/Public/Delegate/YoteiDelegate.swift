//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public protocol YoteiDelegate<Data>: AnyObject {
    associatedtype Data: YoteiEventData

    func calendarDidSelectEvent(with id: YoteiEvent<Data>.ID)
    func calendarDidSelectAllDay(date: Date)
    func calendarDidSelect(dateInterval: DateInterval, completion: () -> Void)
    func calendarDidSelectMonthDay(date: Date)
    func calendarDidUpdateEvent(
        with id: YoteiEvent<Data>.ID,
        oldDateInterval: DateInterval,
        newDateInterval: DateInterval
    )
}

public extension EnvironmentValues {
    @Entry var yoteiDelegate: (any YoteiDelegate)?
}

public extension View {
    func yoteiDelegate(_ delegate: (any YoteiDelegate)?) -> some View {
        environment(\.yoteiDelegate, delegate)
    }
}
