//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import SwiftUI

public struct YoteiAllDayEventsTopView<ViewFactory: YoteiAllDayEventsTopViewFactoryProtocol<Data>, Data: YoteiEventData>: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.yoteiDelegate) private var delegate

    private let startDate: Date
    private let numberOfDays: Int
    @Binding private var data: YoteiEventsInterval<Data>
    private let viewFactory: ViewFactory

    @State private var viewData: AlignedRowEventsData<Data>?
    @State private var task: Task<Void, Never>?

    private var daysSequence: YoteiDaysSequence {
        YoteiDaysSequence(startDate: startDate, days: numberOfDays, calendar: calendar)
    }

    public init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<YoteiEventsInterval<Data>>,
        viewFactory: ViewFactory
    ) {
        _data = data
        self.startDate = startDate
        self.numberOfDays = numberOfDays
        self.viewFactory = viewFactory
    }

    public init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<YoteiEventsInterval<Data>>
    ) where ViewFactory == YoteiAllDayEventsTopViewFactory<Data> {
        self.init(
            startDate: startDate,
            numberOfDays: numberOfDays,
            data: data,
            viewFactory: YoteiAllDayEventsTopViewFactory()
        )
    }

    public var body: some View {
        ZStack {
            if let viewData, !viewData.events.isEmpty {
                eventsGridView(viewData: viewData)
                    .overlay {
                        dayButtonsView()
                    }
                    .padding(viewFactory.insets())
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: data, initial: true, isAsync: true) {
            task?.cancel()
            task = Task {
                viewData = await processData()
            }
        }
    }
}

private extension YoteiAllDayEventsTopView {
    private func processData() async -> AlignedRowEventsData<Data>? {
        let processor = EventsRowAligner<Data>(
            startDate: startDate,
            numberOfDays: numberOfDays,
            calendar: calendar,
            numberOfVisibleRows: viewFactory.numberOfVisibleRows()
        )
        return await processor.calculate(data: data, filter: \.isAllDay)
    }

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
                        case .empty:
                            emptyView()
                        }
                    }
                }
            }

            GridRow {
                ForEach(daysSequence, id: \.self) { date in
                    if let count = viewData.extraCount[date], count > 0 {
                        viewFactory.moreEventsView(count: count)
                    } else {
                        emptyView()
                    }
                }
            }
        }
    }

    func dayButtonsView() -> some View {
        HStack(spacing: 0) {
            ForEach(daysSequence, id: \.self) { date in
                Button(action: {
                    delegate?.calendarDidSelectAllDay(date: date)
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.frame(maxWidth: .infinity)
    }

    func emptyView() -> some View {
        Color.clear
            .frame(height: 0)
            .frame(maxWidth: .infinity)
    }
}
