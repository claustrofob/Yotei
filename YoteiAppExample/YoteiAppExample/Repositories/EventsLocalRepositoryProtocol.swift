//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import Yotei

protocol EventsLocalRepositoryProtocol {
    func events(in dateInterval: DateInterval) async -> [Date: [YoteiEvent]]
}
