//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public protocol YoteiDelegate<Data>: AnyObject {
    associatedtype Data: YoteiEventData

    func calendarDidSelectEvent(with id: YoteiEvent<Data>.ID)
    func calendarDidSelectAllDay(date: Date)
    func calendarDidSelect(dateInterval: DateInterval, completion: () -> Void)
}
