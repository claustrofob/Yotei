//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleView: View {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    @Binding private var focusedDate: Date
    @Binding private var data: YoteiEventsInterval
    private weak var delegate: YoteiDelegate?

    @State private var viewData: YoteiScheduleViewData?

    public init(
        focusedDate: Binding<Date>,
        data: Binding<YoteiEventsInterval>,
        delegate: YoteiDelegate?
    ) {
        _focusedDate = Binding(get: {
            Calendar.current.startOfDay(for: focusedDate.wrappedValue)
        }, set: {
            focusedDate.wrappedValue = $0
        })
        _data = data
        self.delegate = delegate
    }

    public var body: some View {
        ZStack {
            YoteiScheduleCollectionView(
                data: viewData,
                delegate: delegate
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
    func viewDidChange(data: YoteiEventsInterval) {
        guard let dateInterval = data.dateInterval else {
            return
        }

        let data = YoteiDaysSequence(interval: dateInterval).map { date in
            let items: [YoteiScheduleViewModel] = if data.dateLoadingInterval?.contains(date) ?? false {
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
