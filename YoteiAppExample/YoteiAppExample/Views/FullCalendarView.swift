//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct FullCalendarView: View {
    @State private var focusedDate = Date()
    @State private var data = YoteiEventsInterval(
        dateInterval: nil,
        dateLoadingInterval: nil,
        monthInterval: nil,
        events: [:]
    )
    @State private var contentOffset: CGPoint?
    @State private var viewType: CalendarViewType = .day

    var body: some View {
        VStack {
            switch viewType {
            case .schedule:
                YoteiScheduleView(
                    focusedDate: $focusedDate,
                    data: $data,
                    delegate: nil
                )
            case .day:
                YoteiDayView(
                    focusedDate: $focusedDate,
                    data: $data,
                    contentOffset: $contentOffset,
                    delegate: nil
                )
            case .week:
                YoteiWeekView(
                    focusedDate: $focusedDate,
                    data: $data,
                    contentOffset: $contentOffset,
                    delegate: nil
                )
            }
        }
        .navigationTitle("Full calendar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu(content: {
                    ForEach(CalendarViewType.allCases, id: \.self) { value in
                        Button(action: {
                            viewType = value
                        }) {
                            Label {
                                Text(value.title)
                            } icon: {
                                value.icon
                            }
                        }
                    }
                }) {
                    viewType.icon
                }
            }
        }
    }
}
