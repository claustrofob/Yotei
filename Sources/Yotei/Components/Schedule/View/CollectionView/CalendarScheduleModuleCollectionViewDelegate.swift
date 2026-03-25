import Foundation

protocol CalendarScheduleModuleCollectionViewDelegate: AnyObject {
    func calendarCollectionView(shouldSelect viewModel: CalendarScheduleModuleViewModel) -> Bool
    func calendarCollectionView(didSelect viewModel: CalendarScheduleModuleViewModel)
}
