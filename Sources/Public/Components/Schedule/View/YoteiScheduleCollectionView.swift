//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct YoteiScheduleCollectionView<ViewFactory: YoteiScheduleViewFactoryProtocol>: UIViewRepresentable {
    let data: YoteiScheduleViewData?
    let delegate: YoteiDelegate?
    let calendar: Calendar
    let viewFactory: ViewFactory
    let focusedDateUpdate: (Date) -> Void

    func makeUIView(context _: Context) -> YoteiScheduleUICollectionView<ViewFactory> {
        YoteiScheduleUICollectionView(
            calendar: calendar,
            viewFactory: viewFactory,
            delegate: delegate,
            focusedDateUpdate: focusedDateUpdate
        )
    }

    func updateUIView(_ uiView: YoteiScheduleUICollectionView<ViewFactory>, context _: Context) {
        guard let data else {
            return
        }
        uiView.apply(data: data)
    }
}
