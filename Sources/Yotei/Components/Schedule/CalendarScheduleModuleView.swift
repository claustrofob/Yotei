import SwiftUI

struct CalendarScheduleModuleView: View {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    @Binding private var focusedDate: Date
    @Binding private var data: CalendarEventsInterval
    private weak var delegate: CalendarDelegate?

    @State private var viewData: CalendarScheduleModule.ViewData = []

    init(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) {
        _focusedDate = focusedDate
        _data = data
        self.delegate = delegate
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarStripContainerModuleView(focusedDate: $focusedDate)
            CalendarScheduleModuleCollectionView(
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

    private func viewDidChange(data: CalendarEventsInterval, focusedDate: Date) {
        guard
            // Updated focusedDate comes before corresponding dateInterval is loaded.
            // This may cause invalid scrolling behavour
            data.monthInterval.flatMap({ $0.contains(focusedDate) }) != false,
            let dateInterval = data.dateInterval
        else {
            return
        }

        viewData = CalendarDaysSequence(interval: dateInterval).map { date in
            let items: [CalendarScheduleModuleViewModel] = if data.dateLoadingInterval?.contains(date) ?? false {
                [.init(date: date, kind: .loading)]
            } else if let events = data.events[date], !events.isEmpty {
                events.sorted(using: [
                    KeyPathComparator(\CalendarEvent.isAllDaySortable),
                    KeyPathComparator(\CalendarEvent.start),
                    KeyPathComparator(\CalendarEvent.durationSortable),
                ]).map { .init(date: date, kind: .event($0)) }
            } else {
                [.init(date: date, kind: .empty)]
            }
            return (section: date, items: items)
        }
    }
}
