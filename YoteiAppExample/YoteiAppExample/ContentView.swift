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
                NavigationLink("Full calendar", value: Destination.fullCalendar)
                NavigationLink("Customized Day View", value: Destination.dayView)
                NavigationLink("Date Picker", value: Destination.defaultDatePicker)
                NavigationLink("Customized Date Picker", value: Destination.customizedDatePicker)
                NavigationLink("Daily Random Facts", value: Destination.dailyRandomFacts)
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
}

#Preview {
    ContentView()
}
