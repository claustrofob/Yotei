import SwiftUI
import UIKit

struct YoteiScheduleCollectionView: UIViewRepresentable {
    @Binding var focusedDate: Date
    let data: YoteiSchedule.ViewData
    let delegate: YoteiDelegate?

    func makeUIView(context _: Context) -> YoteiScheduleUICollectionView {
        YoteiScheduleUICollectionView(
            factory: YoteiScheduleCollectionViewFactory(),
            delegate: delegate,
            focusedDate: $focusedDate
        )
    }

    func updateUIView(_ uiView: YoteiScheduleUICollectionView, context _: Context) {
        uiView.apply(data: data, focusedDate: $focusedDate)
    }
}
