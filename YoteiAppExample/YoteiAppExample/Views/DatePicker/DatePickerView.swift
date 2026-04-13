//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct DatePickerView: View {
    private let dateFormatStyle = Date.FormatStyle()
    @State private var selectedDate = Date()

    var body: some View {
        YoteiDatePicker(
            selectedDate: $selectedDate,
            minDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        )
        .padding()
        .navigationTitle(selectedDate.formatted(dateFormatStyle))
    }
}
