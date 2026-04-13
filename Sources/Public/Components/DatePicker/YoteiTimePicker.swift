//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiTimePicker: UIViewRepresentable {
    @Binding private var date: Date
    private let minuteInterval: Int
    private let calendar: Calendar

    public init(
        date: Binding<Date>,
        minuteInterval: Int,
        calendar: Calendar
    ) {
        _date = date
        self.minuteInterval = minuteInterval
        self.calendar = calendar
    }

    public func makeUIView(context: Context) -> UIDatePicker {
        let view = UIDatePicker()
        view.preferredDatePickerStyle = .wheels
        view.datePickerMode = .time
        view.roundsToMinuteInterval = true
        view.locale = Locale.time24Hour
        view.calendar = calendar
        view.timeZone = calendar.timeZone
        view.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateDidChange(_:)),
            for: .valueChanged
        )
        return view
    }

    public func updateUIView(_ uiView: UIDatePicker, context _: Context) {
        uiView.date = date
        uiView.minuteInterval = minuteInterval
        uiView.calendar = calendar
        uiView.timeZone = calendar.timeZone
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }
}

public extension YoteiTimePicker {
    @MainActor
    class Coordinator: NSObject {
        @Binding private var date: Date

        init(date: Binding<Date>) {
            _date = date
        }

        @objc func dateDidChange(_ datePicker: UIDatePicker) {
            date = datePicker.date
        }
    }
}
