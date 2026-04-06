//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct ScheduleViewFactory: YoteiScheduleViewFactoryProtocol {
    func eventCellView(date: Date, event: YoteiEvent) -> some View {
        YoteiScheduleEventCellDefaultView(cellDate: date, event: event)
    }

    func emptyCellView(date _: Date) -> some View {
        YoteiScheduleEmptyCellDefaultView()
    }

    func loadingCellView(date _: Date) -> some View {
        YoteiScheduleLoadingCellDefaultView()
    }

    func dayHeaderView(date: Date) -> some View {
        YoteiScheduleSectionDefaultHeaderView(date: date)
    }
}
