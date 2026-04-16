//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDatePicker<ViewFactory: YoteiDatePickerFactoryProtocol>: View {
    enum Constants {
        static var maxNumberOfWeeks: CGFloat { 6 }
    }

    @Environment(\.calendar) private var calendar

    @Binding private var selectedDate: Date
    private let minDate: Date?
    private let maxDate: Date?
    private let viewFactory: ViewFactory

    @State var initialPageDate: Date?

    public init(
        selectedDate: Binding<Date>,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        viewFactory: ViewFactory = YoteiDatePickerFactory()
    ) {
        _selectedDate = selectedDate
        self.viewFactory = viewFactory
        self.minDate = minDate
        self.maxDate = maxDate
    }

    public var body: some View {
        MainView(
            selectedDate: $selectedDate,
            minDate: minDate,
            maxDate: maxDate,
            viewFactory: viewFactory,
            initialPageDate: calendar.dateInterval(
                of: .month,
                for: selectedDate
            )!.start
        )
    }
}

private extension YoteiDatePicker {
    struct MainView: View {
        @Environment(\.calendar) private var calendar

        @Binding var selectedDate: Date
        let minDate: Date?
        let maxDate: Date?
        let viewFactory: ViewFactory

        @State var selectedPageDate: Date
        @State var isMonthYearPickerExpanded = false

        var maxMonthHeight: CGFloat {
            viewFactory.dayCellViewHeight() * Constants.maxNumberOfWeeks
                + viewFactory.weekInteritemVerticalSpacing() * (Constants.maxNumberOfWeeks - 1)
        }

        init(
            selectedDate: Binding<Date>,
            minDate: Date?,
            maxDate: Date?,
            viewFactory: ViewFactory,
            initialPageDate: Date
        ) {
            _selectedDate = selectedDate
            self.minDate = minDate
            self.maxDate = maxDate
            self.viewFactory = viewFactory
            _selectedPageDate = State(initialValue: initialPageDate)
        }

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    monthYearButton()
                    Spacer()
                    if !isMonthYearPickerExpanded {
                        backForwardButtons()
                    }
                }
                .foregroundStyle(.primary)
                HStack {
                    if isMonthYearPickerExpanded {
                        YoteiMonthYearPicker(date: $selectedPageDate)
                    } else {
                        DateTabView(
                            selection: $selectedPageDate,
                            content: { date in
                                YoteiDatePickerMonth(
                                    selectedDate: $selectedDate,
                                    dateInMonth: date,
                                    minDate: minDate,
                                    maxDate: maxDate,
                                    viewFactory: viewFactory
                                )
                            },
                            previousDate: { date in
                                calendar.date(byAdding: .month, value: -1, to: date)!
                            },
                            nextDate: { date in
                                calendar.date(byAdding: .month, value: 1, to: date)!
                            }
                        )
                    }
                }
                .frame(height: maxMonthHeight, alignment: .center)
            }
            .animation(.default, value: isMonthYearPickerExpanded)
            .onChange(of: selectedDate) { _ in
                generateSelectedPageDate()
            }
            .onAppear {
                generateSelectedPageDate()
            }
        }

        func generateSelectedPageDate() {
            selectedPageDate = calendar.dateInterval(
                of: .month,
                for: selectedDate
            )!.start
        }

        func monthYearButton() -> some View {
            Button(action: {
                isMonthYearPickerExpanded.toggle()
            }) {
                viewFactory.monthSelectorButtonView(
                    date: selectedPageDate,
                    isExpanded: isMonthYearPickerExpanded,
                    calendar: calendar
                )
            }
        }

        func backForwardButtons() -> some View {
            HStack(spacing: 4) {
                Button(action: {
                    selectedPageDate = calendar.date(
                        byAdding: .month,
                        value: -1,
                        to: selectedPageDate
                    )!
                }) {
                    viewFactory.monthBackButtonView()
                }

                Button(action: {
                    selectedPageDate = calendar.date(
                        byAdding: .month,
                        value: 1,
                        to: selectedPageDate
                    )!
                }) {
                    viewFactory.monthForwardButtonView()
                }
            }
        }
    }
}
