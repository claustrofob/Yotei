import SwiftUI
import UIKit

struct CalendarScheduleModuleCollectionView: UIViewRepresentable {
    @Binding var focusedDate: Date?
    let data: CalendarScheduleModule.ViewData
    let delegate: CalendarScheduleModuleCollectionViewDelegate

    func makeUIView(context _: Context) -> CalendarScheduleModuleUICollectionView {
        CalendarScheduleModuleUICollectionView(
            factory: CalendarScheduleModuleCollectionViewFactory(),
            delegate: delegate
        )
    }

    func updateUIView(_ uiView: CalendarScheduleModuleUICollectionView, context _: Context) {
        guard let focusedDate else {
            return
        }
        uiView.apply(data: data, focusedDate: $focusedDate)
    }
}
