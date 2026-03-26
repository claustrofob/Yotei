import SwiftUI

struct SUMonthYearPicker: UIViewRepresentable {
    private enum Constants {
        // imitate infinite scrollable list of months (as Apple does in its )
        static var numberOfMonths: Int { 12000 }
        static var numberOfYears: Int { 4000 }
    }

    @Binding private var date: Date
    private let calendar: Calendar

    init(date: Binding<Date>, calendar: Calendar) {
        _date = date
        self.calendar = calendar
    }

    func makeUIView(context: Context) -> UIPickerView {
        let view = UIPickerView()
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        view.selectRow(Constants.numberOfMonths / 2, inComponent: 0, animated: false)
        selectCurrentDate(uiView: view, animated: false)
        return view
    }

    func updateUIView(_ uiView: UIPickerView, context _: Context) {
        selectCurrentDate(uiView: uiView, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date, calendar: calendar)
    }

    private func selectCurrentDate(uiView: UIPickerView, animated: Bool) {
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let selectedMonthSegment = uiView.selectedRow(inComponent: 0) / 12 * 12
        uiView.selectRow(dateComponents.month! - 1 + selectedMonthSegment, inComponent: 0, animated: animated)
        uiView.selectRow(dateComponents.year! - 1, inComponent: 1, animated: animated)
    }
}

extension SUMonthYearPicker {
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        @Binding private var date: Date
        private let calendar: Calendar

        init(date: Binding<Date>, calendar: Calendar) {
            _date = date
            self.calendar = calendar
        }

        func numberOfComponents(in _: UIPickerView) -> Int {
            2
        }

        func pickerView(
            _: UIPickerView,
            numberOfRowsInComponent component: Int
        ) -> Int {
            switch component {
            case 0: Constants.numberOfMonths
            case 1: Constants.numberOfYears
            default: fatalError("Unsupported")
            }
        }

        func pickerView(
            _: UIPickerView,
            titleForRow row: Int,
            forComponent component: Int
        ) -> String? {
            switch component {
            case 0: calendar.standaloneMonthSymbols[row % 12].capitalized
            case 1: "\(row + 1)"
            default: fatalError("Unsupported")
            }
        }

        func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            var dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
            switch component {
            case 0:
                dateComponents.month = row % 12 + 1
            case 1:
                dateComponents.year = row + 1
            default: fatalError("Unsupported")
            }

            date = calendar.date(from: dateComponents)!
        }
    }
}
