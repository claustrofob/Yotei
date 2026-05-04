//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct PagesCalendarComponentKey: PreferenceKey {
    static let defaultValue: Calendar.Component = .day
    static func reduce(value: inout Calendar.Component, nextValue: () -> Calendar.Component) {
        value = nextValue()
    }
}
