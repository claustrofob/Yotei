//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct DailyRandomFactsView: View {
    @StateObject var viewModel = DailyRandomFactsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            YoteiPagesDayView(
                focusedDate: $viewModel.focusedDate
            ) { _ in
                Text("\(Int.random(in: 0 ... 1000))")
            }
            Text(viewModel.focusedDate.formatted(Date.FormatStyle().month(.wide)))
            YoteiStripWeekView(focusedDate: $viewModel.focusedDate)
                .frame(height: YoteiStripViewFactory().dayCellViewHeight())
            YoteiWeekdayTitlesView()
        }
    }
}
