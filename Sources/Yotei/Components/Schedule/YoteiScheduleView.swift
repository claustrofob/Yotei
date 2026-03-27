import Internal
import SwiftUI

struct YoteiScheduleView: View {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    @Binding private var focusedDate: Date
    @Binding private var data: YoteiEventsInterval
    private weak var delegate: YoteiDelegate?

    @State private var viewData: YoteiSchedule.ViewData = []

    init(
        focusedDate: Binding<Date>,
        data: Binding<YoteiEventsInterval>,
        delegate: YoteiDelegate?
    ) {
        _focusedDate = focusedDate
        _data = data
        self.delegate = delegate
    }

    var body: some View {
        VStack(spacing: 0) {
            YoteiStripContainerView(focusedDate: $focusedDate)
            YoteiScheduleCollectionView(
                focusedDate: $focusedDate,
                data: viewData,
                delegate: delegate
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: focusedDate, initial: true) {
            viewDidChange(data: data, focusedDate: focusedDate)
        }
        .onChange(of: data, initial: false) {
            viewDidChange(data: data, focusedDate: focusedDate)
        }
    }

    private func viewDidChange(data: YoteiEventsInterval, focusedDate: Date) {
        guard
            // Updated focusedDate comes before corresponding dateInterval is loaded.
            // This may cause invalid scrolling behavour
            data.monthInterval.flatMap({ $0.contains(focusedDate) }) != false,
            let dateInterval = data.dateInterval
        else {
            return
        }

        viewData = CalendarDaysSequence(interval: dateInterval).map { date in
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
    }
}
