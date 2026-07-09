//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

/// Calendar returns weekday as a number in 1 through N (where for the Gregorian calendar N=7 and 1 is Sunday).
/// This extension returns a list of these numbers in the correct, depending on the first weekday.
///  E.g. if week start on Monday it returns [2,3,4,5,6,7,1]
extension Calendar {
    var weekdayIndices: [Int] {
        let startIndex = firstWeekday
        return (startIndex ... 7).map(\.self) + (1 ..< startIndex).map(\.self)
    }
}

extension Calendar {
    init(identifier: Calendar.Identifier = .gregorian, timeZone: TimeZone) {
        self.init(identifier: identifier)
        self.timeZone = timeZone
    }
}
