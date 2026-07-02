//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct DayView: View {
    @State private var focusedDate = Calendar.current.startOfDay(for: Date())
    @State private var contentOffset: CGPoint?
    @State private var data = YoteiEventsInterval<EventData>()

    var body: some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
            YoteiStripContainerView(
                focusedDate: $focusedDate,
                viewFactory: StripViewFactory()
            )
            YoteiPagesDayView(
                focusedDate: $focusedDate
            ) { date in
                VStack(spacing: 0) {
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 1,
                        data: data,
                        viewFactory: YoteiAllDayEventsTopViewFactory()
                    )
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 6))
                    .background {
                        Text("All day")
                            .font(.system(.caption))
                            .padding(.horizontal, 4)
                            .frame(width: 50)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .clipped()
                    YoteiDayEventsView(
                        startDate: date,
                        numberOfDays: 1,
                        data: data,
                        contentOffset: $contentOffset,
                        viewFactory: DayEventsViewFactory()
                    )
                }
            }
        }
        .tint(.purple)
        .onAppear {
            data.events = [
                focusedDate: [
                    YoteiEvent(title: "Event 1", startOfDay: focusedDate, timeInHours: 2.0, durationInHours: 4.5),
                    YoteiEvent(title: "Event 2", startOfDay: focusedDate, timeInHours: 2.0, durationInHours: 1),
                    YoteiEvent(title: "Event 3", startOfDay: focusedDate, timeInHours: 2.25, durationInHours: 2),
                    YoteiEvent(title: "Event 4", startOfDay: focusedDate, timeInHours: 2.4, durationInHours: 2),
                    YoteiEvent(title: "Event 5", startOfDay: focusedDate, timeInHours: 3, durationInHours: 5),
                    YoteiEvent(title: "Event 6", startOfDay: focusedDate, timeInHours: 3.35, durationInHours: 3),
                    YoteiEvent(title: "Event 7", startOfDay: focusedDate, timeInHours: 3.35, durationInHours: 3),
                    YoteiEvent(title: "Event 8", startOfDay: focusedDate, timeInHours: 3.8, durationInHours: 3),
                    YoteiEvent(title: "Event 9", startOfDay: focusedDate, timeInHours: 3.8, durationInHours: 9),
                    YoteiEvent(title: "Event 10", startOfDay: focusedDate, timeInHours: 3.8, durationInHours: 1.5),
                    YoteiEvent(title: "Event 11", startOfDay: focusedDate, timeInHours: 4.7, durationInHours: 1.5),
                    YoteiEvent(title: "Event 12", startOfDay: focusedDate, timeInHours: 7, durationInHours: 1.5),
                    YoteiEvent(title: "Event 13", startOfDay: focusedDate, timeInHours: 7.5, durationInHours: 1.5),
                    YoteiEvent(title: "Event 14", startOfDay: focusedDate, timeInHours: 8, durationInHours: 1.5),
                    YoteiEvent(title: "Event 15", startOfDay: focusedDate, timeInHours: 8.5, durationInHours: 1.5),
                    YoteiEvent(title: "Event 16", startOfDay: focusedDate, timeInHours: 9, durationInHours: 1.5),
                    YoteiEvent(title: "Event 17", startOfDay: focusedDate, timeInHours: 9.5, durationInHours: 1.5),
                    YoteiEvent(title: "Event 18", startOfDay: focusedDate, timeInHours: 10, durationInHours: 0.5),
                    YoteiEvent(title: "Event 19", startOfDay: focusedDate, timeInHours: 10, durationInHours: 0.5),
                    YoteiEvent(title: "Event 20", startOfDay: focusedDate, timeInHours: 10, durationInHours: 0.5),
                    YoteiEvent(title: "Event 21", startOfDay: focusedDate, timeInHours: 11.2, durationInHours: 2),
                    YoteiEvent(title: "Event 22", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 23", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 24", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 25", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 26", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 27", startOfDay: focusedDate, timeInHours: 11.6, durationInHours: 0.5),
                    YoteiEvent(title: "Event 28", startOfDay: focusedDate, timeInHours: 13.5, durationInHours: 1),
                    YoteiEvent(title: "Event 29", startOfDay: focusedDate, timeInHours: 14.5, durationInHours: 0.5),
                    YoteiEvent(title: "Event 30", startOfDay: focusedDate, timeInHours: 15, durationInHours: 0.25),
                    YoteiEvent(title: "Event 31", startOfDay: focusedDate, timeInHours: 17, durationInHours: 4),
                    YoteiEvent(title: "Event 32", startOfDay: focusedDate, timeInHours: 17, durationInHours: 2.5),
                    YoteiEvent(title: "Event 33", startOfDay: focusedDate, timeInHours: 19.5, durationInHours: 2.5),
                ],
            ]
        }
    }
}

private extension YoteiEvent<EventData> {
    init(
        title: String,
        startOfDay: Date,
        timeInHours: Double,
        durationInHours: Double
    ) {
        let interval = DateInterval(
            start: startOfDay.addingTimeInterval(timeInHours * 3600),
            duration: durationInHours * 3600
        )
        self.init(
            id: UUID().uuidString,
            title: title,
            start: interval.start,
            end: interval.end,
            isAllDay: false,
            data: EventData()
        )
    }
}
