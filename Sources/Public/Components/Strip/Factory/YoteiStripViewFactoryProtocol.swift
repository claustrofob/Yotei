//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiStripViewFactoryProtocol {
    associatedtype ExpandView: View
    func expandView(progress: CGFloat) -> ExpandView

    associatedtype DayCellView: View
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> DayCellView

    func dayCellViewHeight() -> CGFloat
    func weekInteritemVerticalSpacing() -> CGFloat
}

public extension YoteiStripViewFactoryProtocol {
    func expandView(progress: CGFloat) -> some View {
        YoteiStripExpandDefaultView(progress: progress)
    }

    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> some View {
        YoteiDayCellDefaultView(
            date: date,
            todayDate: todayDate,
            focusedDate: focusedDate,
            isEnabled: isEnabled
        )
    }

    func dayCellViewHeight() -> CGFloat {
        40
    }

    func weekInteritemVerticalSpacing() -> CGFloat {
        8
    }
}
