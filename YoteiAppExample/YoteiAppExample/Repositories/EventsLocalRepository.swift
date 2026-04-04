//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import Yotei

struct EventsLocalRepository {}

extension EventsLocalRepository: EventsLocalRepositoryProtocol {
    func events(in _: DateInterval) async -> [Date: [YoteiEvent]] {
        [:]
    }
}
