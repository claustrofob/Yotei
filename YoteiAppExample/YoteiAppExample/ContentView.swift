//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private enum Destination: Hashable {
        case fullCalendar
        case defaultDatePicker
        case customizedDatePicker
        case dayView
        case dailyRandomFacts
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: Destination.fullCalendar) {
                    titleView(text: "Full calendar", subtitle: "All calendar features with the default customization")
                }
                NavigationLink(value: Destination.dayView) {
                    titleView(text: "Customized Day View", subtitle: "An example of customization options")
                }
                NavigationLink(value: Destination.defaultDatePicker) {
                    titleView(text: "Date Picker", subtitle: "Reimplemented Apple's DatePicker with default options")
                }
                NavigationLink(value: Destination.customizedDatePicker) {
                    titleView(text: "Customized Date Picker", subtitle: "An example of a DatePicker customization")
                }
                NavigationLink(value: Destination.dailyRandomFacts) {
                    titleView(text: "Daily Random Facts", subtitle: "Just a small fun app to demonstrate a custom usage of calendar components. Requires iOS26 and a real device with enabled Apple Intelligence.")
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .fullCalendar:
                    FullCalendarView()
                case .defaultDatePicker:
                    DatePickerView()
                case .customizedDatePicker:
                    CustomizedDatePickerView()
                case .dayView:
                    DayView()
                case .dailyRandomFacts:
                    DailyRandomFactsView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Example app")
        }
    }

    private func titleView(text: String, subtitle: String) -> some View {
        VStack(alignment: .leading) {
            Text(text)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
