//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Combine
import Foundation

final class DailyRandomFactsPageViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(String)
        case error(Error)
    }

    @Published var state: State = .loading

    init() {}

    func viewDidAppear(date _: Date) {
        state = .loading
    }
}
