import SwiftUI
import UIKit

struct CalendarScheduleModuleCollectionView: UIViewRepresentable {
    @Binding var focusedDate: Date
    let data: CalendarScheduleModule.ViewData
    let delegate: CalendarDelegate?

    func makeUIView(context _: Context) -> CalendarScheduleModuleUICollectionView {
        CalendarScheduleModuleUICollectionView(
            factory: CalendarScheduleModuleCollectionViewFactory(),
            delegate: delegate,
            focusedDate: $focusedDate
        )
    }

    func updateUIView(_ uiView: CalendarScheduleModuleUICollectionView, context _: Context) {
        uiView.apply(data: data, focusedDate: $focusedDate)
    }
}
