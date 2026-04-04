//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import UIKit

struct YoteiScheduleCollectionView: UIViewRepresentable {
    @Binding var focusedDate: Date
    let data: YoteiScheduleViewData?
    let delegate: YoteiDelegate?

    func makeUIView(context _: Context) -> YoteiScheduleUICollectionView {
        YoteiScheduleUICollectionView(
            factory: YoteiScheduleCollectionViewFactory(),
            delegate: delegate
        ) { date in
            focusedDate = date
        }
    }

    func updateUIView(_ uiView: YoteiScheduleUICollectionView, context _: Context) {
        guard let data else {
            return
        }
        uiView.apply(data: data)
    }
}
