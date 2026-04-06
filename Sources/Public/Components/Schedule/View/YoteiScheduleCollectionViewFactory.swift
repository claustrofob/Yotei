//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
struct YoteiScheduleCollectionViewFactory {
    func eventCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, (Date, YoteiEvent)> {
        .init { cell, _, event in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleEventCellDefaultView(cellDate: event.0, event: event.1)
            }.margins(.all, 0)
        }
    }

    func emptyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleEmptyCellDefaultView()
            }.margins(.all, 0)
        }
    }

    func loadingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Date> {
        .init { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleLoadingCellDefaultView()
            }.margins(.all, 0)
        }
    }

    func headerRegistration(dateByIndexPath: @escaping (IndexPath) -> Date) -> UICollectionView.SupplementaryRegistration<UICollectionViewCell> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, indexPath in
            cell.contentConfiguration = UIHostingConfiguration {
                YoteiScheduleSectionDefaultHeaderView(date: dateByIndexPath(indexPath))
            }.margins(.all, 0)
        }
    }
}
