//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesMonthPageView<ViewFactory: YoteiPagesMonthViewFactoryProtocol, Data: YoteiEventData>: View {
    enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
        static var numberOfRows: Int { 6 }
    }

    @Environment(\.calendar) private var calendar

    @Binding private var selectedDate: Date
    @Binding private var data: YoteiEventsInterval<Data>
    private let dateInMonth: Date
    private let viewFactory: ViewFactory

    @State private var viewData = [Date: AlignedRowEventsData<Data>]()
    @State private var task: Task<Void, Never>?

    public init(
        selectedDate: Binding<Date>,
        dateInMonth: Date,
        data: Binding<YoteiEventsInterval<Data>>,
        viewFactory: ViewFactory
    ) {
        _selectedDate = selectedDate
        self.dateInMonth = dateInMonth
        _data = data
        self.viewFactory = viewFactory
    }

    public init(
        selectedDate: Binding<Date>,
        data: Binding<YoteiEventsInterval<Data>>,
        dateInMonth: Date
    ) where ViewFactory == YoteiPagesMonthViewFactory<Data> {
        _selectedDate = selectedDate
        self.dateInMonth = dateInMonth
        _data = data
        viewFactory = YoteiPagesMonthViewFactory()
    }

    public var body: some View {
        let monthInterval = calendar.dateInterval(of: .month, for: dateInMonth)!
        let startDate = calendar.dateInterval(
            of: .weekOfMonth,
            for: monthInterval.start
        )!.start
        let daysSequence = YoteiDaysSequence(
            startDate: startDate,
            days: Constants.numberOfRows * Constants.numberOfDaysPerWeek,
            calendar: calendar
        )

        let todayDate = Date.now
        ZStack {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0 ..< Constants.numberOfRows, id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            let date = daysSequence[row * Constants.numberOfDaysPerWeek + col]
                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                            Button(action: {
                                selectedDate = date
                            }, label: {
                                viewFactory.dayCellView(
                                    date: date,
                                    todayDate: todayDate,
                                    focusedDate: selectedDate,
                                    isEnabled: isEnabled
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                            })
                            .disabled(!isEnabled)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                viewFactory.horizontalDelimiterView()
                ForEach(0 ..< Constants.numberOfRows, id: \.self) { _ in
                    Spacer()
                    viewFactory.horizontalDelimiterView()
                }
            }

            HStack(spacing: 0) {
                ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                    Spacer()
                    if col != Constants.numberOfDaysPerWeek - 1 {
                        viewFactory.verticalDelimiterView()
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .onChange(of: data, initial: true, isAsync: true) {
            task?.cancel()
            task = Task {
                viewData = await processData(startDate: startDate)
            }
        }
    }
}

private extension YoteiPagesMonthPageView {
    func processData(startDate: Date) async -> [Date: AlignedRowEventsData<Data>] {
        let numberOfDaysPerWeek = Constants.numberOfDaysPerWeek
        let calendar = calendar
        let data = data
        return await withTaskGroup { group in
            for index in 0 ..< Constants.numberOfRows {
                group.addTask {
                    let processor = EventsRowAligner<Data>(
                        startDate: calendar.date(byAdding: .weekOfMonth, value: index, to: startDate)!,
                        numberOfDays: numberOfDaysPerWeek,
                        calendar: calendar,
                        numberOfVisibleRows: 3
                    )
                    return await processor.calculate(data: data, filter: { _ in true })
                }
            }

            var result: [Date: AlignedRowEventsData<Data>] = [:]
            for await value in group {
                result[value.startDate] = value
            }
            return result
        }
    }
}
