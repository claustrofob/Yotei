import UIKit

final class CalendarScheduleDataSource: UICollectionViewDiffableDataSource<
    Date.ID,
    CalendarScheduleViewModel.ID
> {
    private(set) var isUpdating = false

    func apply(snapshot: NSDiffableDataSourceSnapshot<Date.ID, CalendarScheduleViewModel.ID>, animatingDifferences: Bool) {
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
