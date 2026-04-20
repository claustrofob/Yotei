//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Combine
import Foundation

final class DailyRandomFactsViewModel: ObservableObject {
    @Published var focusedDate = Date()

    init() {}
}
