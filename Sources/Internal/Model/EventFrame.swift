//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct EventFrame: Equatable, Sendable {
    let id: String
    let date: Date
    let frame: CGRect
}
