//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleView<ViewFactory: YoteiScheduleViewFactoryProtocol, Data: YoteiEventData>: View where ViewFactory.Data == Data {
    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    @Binding private var data: YoteiEventsInterval<Data>
    private let viewFactory: ViewFactory

    @State private var viewData: YoteiScheduleViewData<Data>?

    public init(
        focusedDate: Binding<Date>,
        data: Binding<YoteiEventsInterval<Data>>,
        viewFactory: ViewFactory
    ) {
        _focusedDate = focusedDate
        _data = data
        self.viewFactory = viewFactory
    }

    public init(
        focusedDate: Binding<Date>,
        data: Binding<YoteiEventsInterval<Data>>
    ) where ViewFactory == YoteiScheduleViewFactory<Data> {
        self.init(
            focusedDate: focusedDate,
            data: data,
            viewFactory: YoteiScheduleViewFactory()
        )
    }

    public var body: some View {
        ZStack {
            YoteiScheduleCollectionView(
                data: viewData,
                viewFactory: viewFactory
            ) {
                viewData?.focusedDate = $0
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onChange(of: focusedDate, initial: false, isAsync: true) {
            // Updated focusedDate comes before corresponding dateInterval is loaded.
            // This may cause invalid scrolling behavour
            guard
                data.monthInterval.flatMap({ $0.contains(focusedDate) }) != false,
                viewData?.focusedDate != focusedDate
            else {
                return
            }
            viewData?.focusedDate = focusedDate
        }
        .onChange(of: data, initial: true, isAsync: true) {
            viewDidChange(data: data)
        }
        .onChange(of: viewData?.focusedDate) { value in
            guard let value, value != focusedDate else {
                return
            }
            focusedDate = value
        }
    }
}

private extension YoteiScheduleView {
    func viewDidChange(data: YoteiEventsInterval<Data>) {
        guard let dateInterval = data.dateInterval else {
            return
        }

        let data = YoteiDaysSequence(interval: dateInterval, calendar: calendar).map { date in
            let items: [YoteiScheduleViewModel<Data>] = if data.dateLoadingInterval?.contains(date) ?? false {
                [.init(date: date, kind: .loading)]
            } else if let events = data.events[date], !events.isEmpty {
                events.sorted(using: [
                    KeyPathComparator(\YoteiEvent.isAllDaySortable),
                    KeyPathComparator(\YoteiEvent.start),
                    KeyPathComparator(\YoteiEvent.durationSortable),
                ]).map { .init(date: date, kind: .event($0)) }
            } else {
                [.init(date: date, kind: .empty)]
            }
            return (section: date, items: items)
        }

        viewData = YoteiScheduleViewData(focusedDate: focusedDate, data: data)
    }
}
