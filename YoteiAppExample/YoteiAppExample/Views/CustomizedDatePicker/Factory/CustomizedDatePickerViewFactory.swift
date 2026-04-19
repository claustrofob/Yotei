//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct CustomizedDatePickerViewFactory: YoteiDatePickerFactoryProtocol {
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> some View {
        let isWeekend = Calendar.current.isDateInWeekend(date)
        return YoteiDatePickerFactory().dayCellView(
            date: date,
            todayDate: todayDate,
            focusedDate: focusedDate,
            isEnabled: isEnabled
        )
        .background {
            Circle().stroke(isWeekend ? .cyan : .clear)
        }
    }

    func monthBackButtonView() -> some View {
        Text("←").font(.title2).fontWeight(.bold)
    }

    func monthForwardButtonView() -> some View {
        Text("→").font(.title2).fontWeight(.bold)
    }
}
