import SwiftUI

struct SUTimePicker: UIViewRepresentable {
    @Binding private var date: Date
    private let minuteInterval: Int
    private let calendar: Calendar

    init(
        date: Binding<Date>,
        minuteInterval: Int,
        calendar: Calendar = .current
    ) {
        _date = date
        self.minuteInterval = minuteInterval
        self.calendar = calendar
    }

    func makeUIView(context: Context) -> UIDatePicker {
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

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
        uiView.minuteInterval = minuteInterval
        uiView.calendar = calendar
        uiView.timeZone = calendar.timeZone
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }
}

extension SUTimePicker {
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
