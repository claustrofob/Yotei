//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct YoteiScheduleCollectionView<ViewFactory: YoteiScheduleViewFactoryProtocol<Data>, Data: YoteiEventData>: UIViewRepresentable {
    @Environment(\.calendar) private var calendar
    @Environment(\.yoteiDelegate) private var delegate

    let data: YoteiScheduleViewData<Data>?
    let viewFactory: ViewFactory
    let focusedDateUpdate: (Date) -> Void

    func makeUIView(context _: Context) -> YoteiScheduleUICollectionView<ViewFactory, Data> {
        YoteiScheduleUICollectionView(
            viewFactory: viewFactory,
            delegate: delegate,
            calendar: calendar,
            focusedDateUpdate: focusedDateUpdate
        )
    }

    func updateUIView(_ uiView: YoteiScheduleUICollectionView<ViewFactory, Data>, context _: Context) {
        uiView.calendar = calendar
        uiView.viewFactory = viewFactory
        uiView.focusedDateUpdate = focusedDateUpdate
        uiView.calendarDelegate = delegate
        guard let data else {
            return
        }
        uiView.apply(data: data)
    }
}
