import SwiftUI
import UIKit

struct CalendarScheduleCollectionView: UIViewRepresentable {
    @Binding var focusedDate: Date
    let data: CalendarSchedule.ViewData
    let delegate: CalendarDelegate?

    func makeUIView(context _: Context) -> CalendarScheduleUICollectionView {
        CalendarScheduleUICollectionView(
            factory: CalendarScheduleCollectionViewFactory(),
            delegate: delegate,
            focusedDate: $focusedDate
        )
    }

    func updateUIView(_ uiView: CalendarScheduleUICollectionView, context _: Context) {
        uiView.apply(data: data, focusedDate: $focusedDate)
    }
}
