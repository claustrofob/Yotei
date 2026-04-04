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

    private let hapticFeedbackGenerator = UISelectionFeedbackGenerator()
    private let currentMonthFormatStyle = Date.FormatStyle().month(.wide)
    private let monthYearFormatStyle = Date.FormatStyle().month().year(.defaultDigits)

    @StateObject private var viewModel = FullCalendarViewModelModel(
        eventsLocalRepository: EventsLocalRepository()
    )

    @State private var contentOffset: CGPoint?

    var body: some View {
        VStack {
            switch viewModel.viewType {
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
                viewModel.focusedDate,
                equalTo: Date(),
                toGranularity: .year
            )
                ? viewModel.focusedDate.formatted(currentMonthFormatStyle)
                : viewModel.focusedDate.formatted(monthYearFormatStyle)
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu(content: {
                    ForEach(CalendarViewType.allCases, id: \.self) { value in
                        Button(action: {
                            viewModel.viewType = value
                        }) {
                            Label {
                                Text(value.title)
                            } icon: {
                                value.icon
                            }
                        }
                    }
                }) {
                    viewModel.viewType.icon
                }
            }
        }
        .onChange(of: viewModel.focusedDate) { _ in
            hapticFeedbackGenerator.selectionChanged()
            viewModel.viewDidChangeFocusedDate()
        }
    }

    @ViewBuilder
    private func scheduleView() -> some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $viewModel.focusedDate)
            YoteiScheduleView(
                focusedDate: $viewModel.focusedDate,
                data: $viewModel.data,
                delegate: nil
            )
        }
    }

    @ViewBuilder
    private func dayView() -> some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $viewModel.focusedDate)
            YoteiPagesDayView(
                focusedDate: $viewModel.focusedDate
            ) { date in
                VStack(spacing: 0) {
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 1,
                        data: $viewModel.data,
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
                        data: $viewModel.data,
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
                focusedDate: $viewModel.focusedDate
            ) { date in
                VStack(spacing: 0) {
                    YoteiWeekdaysView(weekStartDate: date)
                        .padding(Constants.weekTitlesViewInsets)
                        .padding(.bottom, 4)
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 7,
                        data: $viewModel.data,
                        delegate: nil
                    )
                    .padding(Constants.weekTitlesViewInsets)
                    YoteiDayEventsView(
                        startDate: date,
                        numberOfDays: 7,
                        data: $viewModel.data,
                        contentOffset: $contentOffset,
                        delegate: nil
                    )
                }
            }
        }
    }
}
