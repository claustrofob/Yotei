//
//  DailyRandomFactsView.swift
//  YoteiAppExample
//
//  Created by Mikalai Zmachynski on 20/04/2026.
//

import Yotei
import SwiftUI

struct DailyRandomFactsView: View {
    @StateObject var viewModel = DailyRandomFactsViewModel()
    
    var body: some View {
        YoteiWeekdayTitlesView()
        YoteiStripContainerView(focusedDate: $viewModel.focusedDate)
        Text(viewModel.focusedDate.formatted(date: .abbreviated, time: .omitted))
        VStack(spacing: 0) {
            YoteiPagesDayView(
                focusedDate: $viewModel.focusedDate
            ) { date in
                Text("\(Int.random(in: 0...1000))")
            }
        }
    }
}
