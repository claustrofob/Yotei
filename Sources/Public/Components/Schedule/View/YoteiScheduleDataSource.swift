//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import UIKit

final class YoteiScheduleDataSource: UICollectionViewDiffableDataSource<
    Date.ID,
    YoteiScheduleViewModel.ID
> {
    private(set) var isUpdating = false

    func apply(snapshot: NSDiffableDataSourceSnapshot<Date.ID, YoteiScheduleViewModel.ID>, animatingDifferences: Bool) {
        // `targetContentOffsetForProposedContentOffset` requires `animatingDifferences = true`,
        let applySnapshot = {
            self.isUpdating = true
            self.apply(snapshot, animatingDifferences: true) {
                self.isUpdating = false
            }
        }

        if animatingDifferences {
            applySnapshot()
        } else {
            UIView.performWithoutAnimation {
                applySnapshot()
            }
        }
    }
}
