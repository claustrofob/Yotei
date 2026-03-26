import Foundation

final class CalendarScheduleModulePresenter: ObservableObject {
    @Published var viewData: CalendarScheduleModule.ViewData = []

    private var prevFocusedDate: Date?
    private weak var delegate: CalendarDelegate?

    init(delegate: CalendarDelegate?) {
        self.delegate = delegate
    }
}

extension CalendarScheduleModulePresenter {
    func viewDidChange(data: CalendarEventsInterval, focusedDate: Date) {
        guard
            prevFocusedDate != focusedDate,
            // Updated focusedDate comes before corresponding dateInterval is loaded.
            // This may cause invalid scrolling behavour
            data.monthInterval.flatMap { $0.contains(focusedDate) } != false,
            let dateInterval = data.dateInterval
        else {
            return
        }

        prevFocusedDate = focusedDate
        viewData = CalendarDaysSequence(interval: dateInterval).map { date in
            let items: [CalendarScheduleModuleViewModel] = if data.dateLoadingInterval?.contains(date) ?? false {
                [.init(date: date, kind: .loading)]
            } else if let events = data.events[date], !events.isEmpty {
                events.sorted(using: [
                    KeyPathComparator(\CalendarEvent.isAllDaySortable),
                    KeyPathComparator(\CalendarEvent.startTimestamp),
                    KeyPathComparator(\CalendarEvent.durationSortable),
                ]).map { .init(date: date, kind: .event($0)) }
            } else {
                [.init(date: date, kind: .empty)]
            }
            return (section: date, items: items)
        }
    }
}

extension CalendarScheduleModulePresenter: CalendarScheduleModuleCollectionViewDelegate {
    func calendarCollectionView(shouldSelect viewModel: CalendarScheduleModuleViewModel) -> Bool {
        switch viewModel.kind {
        case .event:
            true
        case .empty, .loading:
            false
        }
    }

    func calendarCollectionView(didSelect viewModel: CalendarScheduleModuleViewModel) {
        switch viewModel.kind {
        case let .event(item):
            delegate?.calendarScheduleModuleDidSelectEvent(with: item.serverID)
        case .empty, .loading:
            ()
        }
    }
}
