import SwiftUI
import UIKit

@MainActor
struct CalendarScheduleModuleCollectionViewFactory {
    func layout() -> CalendarScheduleModuleCollectionViewLayout {
        CalendarScheduleModuleCollectionViewLayout()
    }

    func eventCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, (Date, CalendarEvent)> {
        .init { cell, _, viewModel in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleModuleCollectionViewEventCell(cellDate: viewModel.0, viewModel: viewModel.1)
            }.margins(.all, 0)
        }
    }

    func emptyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleModuleCollectionViewEmptyCell()
            }.margins(.all, 0)
        }
    }

    func loadingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarScheduleModuleCollectionViewLoadingCell()
            }.margins(.all, 0)
        }
    }

    func headerRegistration() -> UICollectionView.SupplementaryRegistration<CalendarScheduleModuleSectionHeaderView> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }
    }
}
