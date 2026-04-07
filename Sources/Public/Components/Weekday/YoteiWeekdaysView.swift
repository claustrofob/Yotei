//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiWeekdaysView: View {
    private let weekStartDate: Date

    public init(weekStartDate: Date) {
        self.weekStartDate = weekStartDate
    }

    public var body: some View {
        TimelineView(.everyMinute) { context in
            HStack(spacing: 0) {
                ForEach(YoteiDaysSequence(startDate: weekStartDate, days: 7), id: \.self) { date in
                    YoteiDayCellDefaultView(date: date, todayDate: context.date)
                }
            }
        }
    }
}
