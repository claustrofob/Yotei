//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct DailyRandomFactsPageView: View {
    let date: Date

    @StateObject private var viewModel = DailyRandomFactsPageViewModel()

    var body: some View {
        Text("Fact of the day")
            .font(.title)
        ScrollView(.vertical) {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .loaded(text):
                Text(text)
                    .font(.title2)
                    .padding()
            case let .error(error):
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            viewModel.viewDidAppear(date: date)
        }
    }
}
