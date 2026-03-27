import SwiftUI
import UIKit

@MainActor
struct CalendarScheduleCollectionViewFactory {
    func layout() -> CalendarScheduleCollectionViewLayout {
        CalendarScheduleCollectionViewLayout()
    }

    func eventCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, (Date, CalendarEvent)> {
        .init { cell, _, viewModel in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleCollectionViewEventCell(cellDate: viewModel.0, viewModel: viewModel.1)
            }.margins(.all, 0)
        }
    }

    func emptyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleCollectionViewEmptyCell()
            }.margins(.all, 0)
        }
    }

    func loadingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleCollectionViewLoadingCell()
            }.margins(.all, 0)
        }
    }

    func headerRegistration() -> UICollectionView.SupplementaryRegistration<CalendarScheduleSectionHeaderView> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }
    }
}
