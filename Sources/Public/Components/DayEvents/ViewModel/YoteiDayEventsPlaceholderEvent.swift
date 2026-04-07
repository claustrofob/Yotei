//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import UIKit

struct YoteiDayEventsPlaceholderEvent {
    let dateInterval: DateInterval

    func frame(
        hourSlotHeight: CGFloat,
        daySlotWidth: CGFloat,
        initialDate: Date
    ) -> CGRect {
        let startDate = dateInterval.start
        let endDate = dateInterval.end

        let pointsPerSecond = hourSlotHeight / 3600
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let originY = max(startDate.timeIntervalSince(startOfDay), 0) * pointsPerSecond
        let height = endDate.timeIntervalSince(startDate) * pointsPerSecond
        let dayIndex = Calendar.current.dateComponents([.day], from: initialDate, to: startDate).day!
        let originX = CGFloat(dayIndex) * daySlotWidth

        return CGRect(
            x: originX,
            y: originY,
            width: daySlotWidth,
            height: height
        )
    }
}
