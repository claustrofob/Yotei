//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct YoteiScheduleCollectionView: UIViewRepresentable {
    let data: YoteiScheduleViewData?
    let delegate: YoteiDelegate?
    let focusedDateUpdate: (Date) -> Void

    func makeUIView(context _: Context) -> YoteiScheduleUICollectionView {
        YoteiScheduleUICollectionView(
            factory: YoteiScheduleCollectionViewFactory(),
            delegate: delegate,
            focusedDateUpdate: focusedDateUpdate
        )
    }

    func updateUIView(_ uiView: YoteiScheduleUICollectionView, context _: Context) {
        guard let data else {
            return
        }
        uiView.apply(data: data)
    }
}
