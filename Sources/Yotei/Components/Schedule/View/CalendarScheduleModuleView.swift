import SwiftUI

struct CalendarScheduleModuleView: View {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    @Binding var focusedDate: Date
    @Binding var data: CalendarEventsInterval

    @StateObject var presenter: CalendarScheduleModulePresenter

    init(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) {
        _focusedDate = focusedDate
        _data = data
        _presenter = .init(wrappedValue: CalendarScheduleModulePresenter(delegate: delegate))
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarStripContainerModuleBuilder().view(focusedDate: $focusedDate)
            CalendarScheduleModuleCollectionView(
                focusedDate: $focusedDate,
                data: presenter.viewData,
                delegate: presenter
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
