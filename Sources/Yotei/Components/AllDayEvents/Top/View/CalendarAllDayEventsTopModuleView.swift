import Foundation
import SwiftUI

struct CalendarAllDayEventsTopModuleView: View {
    @Environment(\.theme) private var theme

    @StateObject var presenter: CalendarAllDayEventsTopModulePresenter
    @Binding var data: CalendarEventsInterval

    init(
        startDate: Date,
        numberOfDays: Int,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) {
        _data = data
        _presenter = .init(wrappedValue: {
            return CalendarAllDayEventsTopModulePresenter(
                startDate: startDate,
                numberOfDays: numberOfDays,
                delegate: delegate
            )
        }())
    }

    var body: some View {
        ZStack {
            if !presenter.viewData.isEmpty {
                eventsGridView()
                    .overlay {
                        dayButtonsView()
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 2, trailing: 0))
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: data, initial: true) { _, value in
            presenter.viewDidChange(data: value)
        }
    }

    private func eventsGridView() -> some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 2) {
            ForEach(0 ..< presenter.viewData.count, id: \.self) { rowIndex in
                let rowData = presenter.viewData[rowIndex]
                GridRow {
                    ForEach(rowData, id: \.id) { item in
                        switch item {
                        case let .event(event: event, cols: cols):
                            eventView(event: event)
                                .gridCellColumns(cols)
                        case .empty:
                            emptyView()
                        }
                    }
                }
            }

            GridRow {
                let sequence = CalendarDaysSequence(startDate: presenter.startDate, days: presenter.numberOfDays)
                ForEach(sequence, id: \.self) { date in
                    if let count = presenter.otherEventsCount[date], count > 0 {
                        moreItemsView(count: count)
                    } else {
                        emptyView()
                    }
                }
            }
        }
    }

    private func dayButtonsView() -> some View {
        HStack(spacing: 0) {
            let sequence = CalendarDaysSequence(startDate: presenter.startDate, days: presenter.numberOfDays)
            ForEach(sequence, id: \.self) { date in
                Button(action: {
                    presenter.viewDidSelect(date: date)
                }) {
                    Color.clear
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func eventView(event: CalendarEvent) -> some View {
        Text(event.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(theme.palette.brandSecondary70.suColor)
            .themeFont(.caption2)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(theme.palette.brandSecondary70.suColor.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }

    private func moreItemsView(count: Int) -> some View {
        Text("+\(count)")
            .lineLimit(1)
            .foregroundStyle(theme.palette.base90.suColor)
            .themeFont(.caption2)
            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .fill(theme.palette.base20.suColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }

    private func emptyView() -> some View {
        Color.clear
            .frame(height: 0)
            .frame(maxWidth: .infinity)
    }
}
