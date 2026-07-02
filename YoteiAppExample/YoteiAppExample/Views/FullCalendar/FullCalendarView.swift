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
            case .month:
                monthView()
            }
        }
        .fontDesign(.serif)
        .yoteiDelegate(viewModel)
        .navigationTitle(
            viewModel.calendar.isDate(
                viewModel.focusedDate,
                equalTo: Date(),
                toGranularity: .year
            )
                ? viewModel.focusedDate.formatted(Date.FormatStyle(
                    calendar: viewModel.calendar,
                    timeZone: viewModel.calendar.timeZone
                ).month(.wide))
                : viewModel.focusedDate.formatted(Date.FormatStyle(
                    calendar: viewModel.calendar,
                    timeZone: viewModel.calendar.timeZone
                ).month().year(.defaultDigits))
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Today") {
                    viewModel.viewDidSelectToday()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.viewDidSelectTimezoneSelector()
                }) {
                    Image(.timezoneIcon)
                }
            }
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
        .environment(\.calendar, viewModel.calendar)
        .onChange(of: viewModel.focusedDate) { _ in
            hapticFeedbackGenerator.selectionChanged()
            viewModel.viewDidChangeFocusedDate()
        }
        .onAppear {
            viewModel.viewDidChangeFocusedDate()
        }
        .sheet(isPresented: $viewModel.isTimezoneSelectorActive) {
            TimezoneSelectorView(timezone: Binding(get: {
                viewModel.calendar.timeZone.identifier
            }, set: {
                guard let id = $0 else {
                    return
                }
                viewModel.viewDidSelectTimezone(with: id)
            }))
        }
        .id(viewModel.viewID)
        // reacting on system updates
        .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
            viewModel.viewDidUpdateUserSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemClockDidChange)) { _ in
            // TimelineView does not immediately fire updates if user sets system clock back.
            // See comments in YoteiDayEventsView
            viewModel.viewDidUpdateUserSettings()
        }
    }

    @ViewBuilder
    private func scheduleView() -> some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
            YoteiStripContainerView(focusedDate: $viewModel.focusedDate)
            YoteiScheduleView(
                focusedDate: $viewModel.focusedDate,
                data: viewModel.data
            )
        }
    }

    @ViewBuilder
    private func dayView() -> some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
            YoteiStripContainerView(focusedDate: $viewModel.focusedDate)
            YoteiDragEventView(
                data: viewModel.data,
                contentOffset: $contentOffset,
                focusedDate: $viewModel.focusedDate
            ) {
                YoteiPagesDayView(
                    focusedDate: $viewModel.focusedDate
                ) { date in
                    VStack(spacing: 0) {
                        YoteiAllDayEventsTopView(
                            startDate: date,
                            numberOfDays: 1,
                            data: viewModel.data
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
                            data: viewModel.data,
                            contentOffset: $contentOffset
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func weekView() -> some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
                .padding(Constants.weekTitlesViewInsets)

            YoteiDragEventView(
                data: viewModel.data,
                contentOffset: $contentOffset,
                focusedDate: $viewModel.focusedDate
            ) {
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
                            data: viewModel.data
                        )
                        .padding(Constants.weekTitlesViewInsets)
                        YoteiDayEventsView(
                            startDate: date,
                            numberOfDays: 7,
                            data: viewModel.data,
                            contentOffset: $contentOffset
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func monthView() -> some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
            YoteiPagesMonthView(
                focusedDate: $viewModel.focusedDate
            ) { date in
                YoteiPagesMonthPageView(
                    selectedDate: $viewModel.focusedDate,
                    data: viewModel.data,
                    dateInMonth: date
                )
            }
        }
    }
}
