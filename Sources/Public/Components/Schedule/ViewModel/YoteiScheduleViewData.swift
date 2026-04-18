//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation

struct YoteiScheduleViewData<Data: YoteiEventData> {
    var focusedDate: Date
    var data: [(section: Date, items: [YoteiScheduleViewModel<Data>])]
}
