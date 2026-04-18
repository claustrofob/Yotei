//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

public protocol YoteiDelegate: AnyObject {
    func calendarDidSelectEvent(with id: YoteiEvent.ID)
    func calendarDidSelectAllDay(date: Date)
    func calendarDidSelect(dateInterval: DateInterval, completion: () -> Void)
}
