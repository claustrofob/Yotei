//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

extension DateInterval {
    func durationInDays(in calendar: Calendar) -> Int {
        calendar.dateComponents(
            [.day],
            from: start,
            to: end
        ).day!
    }
}
