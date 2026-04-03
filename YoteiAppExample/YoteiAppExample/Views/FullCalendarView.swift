//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct FullCalendarView: View {
    private enum Constants {
        static var weekTitlesViewInsets: EdgeInsets {
            EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0)
        }
    }

    private let currentMonthFormatStyle = Date.FormatStyle().month(.wide)
    private let monthYearFormatStyle = Date.FormatStyle().month().year(.defaultDigits)

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
                scheduleView()
            case .day:
                dayView()
            case .week:
                weekView()
            }
        }
        .navigationTitle(
            Calendar.current.isDate(
                focusedDate,
                equalTo: Date(),
                toGranularity: .year
            )
                ? focusedDate.formatted(currentMonthFormatStyle)
                : focusedDate.formatted(monthYearFormatStyle)
        )
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

    @ViewBuilder
    private func scheduleView() -> some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $focusedDate)
            YoteiScheduleView(
                focusedDate: $focusedDate,
                data: $data,
                delegate: nil
            )
        }
    }

    @ViewBuilder
    private func dayView() -> some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $focusedDate)
            YoteiPagesDayView(
                focusedDate: $focusedDate
            ) { date in
                VStack(spacing: 0) {
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 1,
                        data: $data,
                        delegate: nil
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
                        data: $data,
                        contentOffset: $contentOffset,
                        delegate: nil
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func weekView() -> some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView(spacing: 0)
                .padding(Constants.weekTitlesViewInsets)

            YoteiPagesWeekView(
                focusedDate: $focusedDate
            ) { date in
                VStack(spacing: 0) {
                    YoteiWeekdaysView(weekStartDate: date)
                        .padding(Constants.weekTitlesViewInsets)
                        .padding(.bottom, 4)
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 7,
                        data: $data,
                        delegate: nil
                    )
                    .padding(Constants.weekTitlesViewInsets)
                    YoteiDayEventsView(
                        startDate: date,
                        numberOfDays: 7,
                        data: $data,
                        contentOffset: $contentOffset,
                        delegate: nil
                    )
                }
            }
        }
    }
}
