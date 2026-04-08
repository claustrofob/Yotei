//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiWeekdayViewFactoryProtocol {
    associatedtype DayCellView: View
    func dayCellView(date: Date, todayDate: Date) -> DayCellView
}

public extension YoteiWeekdayViewFactoryProtocol {
    func dayCellView(date: Date, todayDate: Date) -> some View {
        YoteiDayCellDefaultView(date: date, todayDate: todayDate)
    }
}
