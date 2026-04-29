//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

extension CGRect {
    func rounded() -> CGRect {
        .init(
            x: origin.x.rounded(),
            y: origin.y.rounded(),
            width: size.width.rounded(),
            height: size.height.rounded()
        )
    }
}
