//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

extension DateInterval {
    var durationInDays: Int {
        Calendar.current.dateComponents(
            [.day],
            from: start,
            to: end
        ).day!
    }
}
