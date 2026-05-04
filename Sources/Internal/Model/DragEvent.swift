//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

enum DragEvent: Equatable {
    case began(location: CGPoint)
    case changed(translation: CGPoint, location: CGPoint)
    case ended
}
