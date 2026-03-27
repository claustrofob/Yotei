//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
struct YoteiScheduleCollectionViewFactory {
    func layout() -> YoteiScheduleCollectionViewLayout {
        YoteiScheduleCollectionViewLayout()
    }

    func eventCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, (Date, YoteiEvent)> {
        .init { cell, _, viewModel in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleCollectionViewEventCell(cellDate: viewModel.0, viewModel: viewModel.1)
            }.margins(.all, 0)
        }
    }

    func emptyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleCollectionViewEmptyCell()
            }.margins(.all, 0)
        }
    }

    func loadingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleCollectionViewLoadingCell()
            }.margins(.all, 0)
        }
    }

    func headerRegistration() -> UICollectionView.SupplementaryRegistration<YoteiScheduleSectionHeaderView> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }
    }
}
