//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

enum DragEvent: Equatable {
    case began(location: CGPoint)
    case changed(translation: CGPoint, location: CGPoint, velocity: CGPoint)
    case ended

    var isActive: Bool {
        switch self {
        case .began:
            true
        case .changed:
            true
        case .ended:
            false
        }
    }
}
