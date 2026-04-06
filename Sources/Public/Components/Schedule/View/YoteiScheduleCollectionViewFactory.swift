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

    func headerRegistration() -> UICollectionView.SupplementaryRegistration<YoteiScheduleSectionHeaderView> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }
    }
}
