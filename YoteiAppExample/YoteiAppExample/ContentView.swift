//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private enum Destination: Hashable {
        case fullCalendar
        case datePicker
        case dayView
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Full calendar", value: Destination.fullCalendar)
                NavigationLink("Date Picker", value: Destination.datePicker)
                NavigationLink("Customized Day View", value: Destination.dayView)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .fullCalendar:
                    FullCalendarView()
                case .datePicker:
                    DatePickerView()
                case .dayView:
                    DayView()
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
