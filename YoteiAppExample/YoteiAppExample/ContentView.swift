//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private enum Destination: Hashable {
        case fullCalendar
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Full calendar", value: Destination.fullCalendar)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .fullCalendar:
                    FullCalendarView()
                }
            }
            .navigationTitle("Example app")
        }
    }
}

#Preview {
    ContentView()
}
