//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiPagesMonthPageView<ViewFactory: YoteiPagesMonthViewFactoryProtocol<Data>, Data: YoteiEventData>: View {
    enum Constants {
        static var numberOfDaysPerWeek: Int { 7 }
        static var numberOfRows: Int { 6 }
        static var minNumberOfVisibleEventRows: Int { 3 }
    }

    @Environment(\.calendar) private var calendar
    @Environment(\.yoteiDelegate) private var delegate

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
        GeometryReader { proxy in
            ScrollView(.vertical) {
                ZStack {
                    VStack(spacing: 0) {
                        let minCellHeight = CGFloat(Constants.minNumberOfVisibleEventRows) * viewFactory.eventViewHeight()
                            + CGFloat(Constants.minNumberOfVisibleEventRows - 1) * viewFactory.interitemVerticalSpacing()

                        viewFactory.horizontalDelimiterView()
                        ForEach(0 ..< Constants.numberOfRows, id: \.self) { row in
                            ZStack(alignment: .top) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                                            let date = daysSequence[row * Constants.numberOfDaysPerWeek + col]
                                            let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                                            viewFactory.dayCellView(
                                                date: date,
                                                todayDate: todayDate,
                                                focusedDate: selectedDate,
                                                isEnabled: isEnabled
                                            )
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }

                                    GeometryReader { _ in
                                        ZStack(alignment: .top) {
                                            // TODO: calculate tiles count
                                            let weekStartDate = daysSequence[row * Constants.numberOfDaysPerWeek]
                                            if let viewData = viewData[weekStartDate] {
                                                eventsGridView(viewData: viewData)
                                            }
                                        }
                                        .frame(maxHeight: .infinity, alignment: .top)
                                    }
                                    .frame(minHeight: minCellHeight)
                                    .clipped()

                                    viewFactory.horizontalDelimiterView()
                                }

                                HStack(spacing: 0) {
                                    ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                                        let date = daysSequence[row * Constants.numberOfDaysPerWeek + col]
                                        let isEnabled = monthInterval.contains(date) && monthInterval.end != date
                                        Button(action: {
                                            delegate?.calendarDidSelectMonthDay(date: date)
                                        }, label: {
                                            Color.clear
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .contentShape(Rectangle())
                                        })
                                        .disabled(!isEnabled)
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 0) {
                        ForEach(0 ..< Constants.numberOfDaysPerWeek, id: \.self) { col in
                            Spacer()
                            if col != Constants.numberOfDaysPerWeek - 1 {
                                viewFactory.verticalDelimiterView()
                            }
                        }
                    }
                }
                .frame(minHeight: proxy.size.height, maxHeight: .infinity, alignment: .center)
            }
        }
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

    @ViewBuilder
    func eventsGridView(viewData: AlignedRowEventsData<Data>) -> some View {
        Grid(
            horizontalSpacing: viewFactory.interitemHorizontalSpacing(),
            verticalSpacing: viewFactory.interitemVerticalSpacing()
        ) {
            ForEach(0 ..< viewData.events.count, id: \.self) { rowIndex in
                let rowData = viewData.events[rowIndex]
                GridRow {
                    ForEach(rowData, id: \.id) { item in
                        switch item {
                        case let .event(event: event, cols: cols):
                            viewFactory.eventView(event: event)
                                .gridCellColumns(cols)
                        case let .extra(index: _, count: count):
                            viewFactory.moreEventsView(count: count)
                        case .empty:
                            emptyView()
                        }
                    }
                }
            }
        }
    }

    func emptyView() -> some View {
        Color.clear
            .frame(height: 0)
            .frame(maxWidth: .infinity)
    }
}
