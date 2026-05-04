//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct EventTimelineFramesKey: PreferenceKey {
    static let defaultValue: [Date: [EventFrame]] = [:]
    static func reduce(value: inout [Date: [EventFrame]], nextValue: () -> [Date: [EventFrame]]) {
        value.merge(nextValue(), uniquingKeysWith: {
            $0 + $1
        })
    }
}
