//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiStripViewFactoryProtocol {
    associatedtype ExpandView: View
    func expandView(isExpanded: Bool) -> ExpandView

    associatedtype DayCellView: View
    func dayCellView(
        date: Date,
        todayDate: Date,
        focusedDate: Date?,
        isEnabled: Bool
    ) -> DayCellView

    func weekInteritemVerticalSpacing() -> CGFloat
}

public extension YoteiStripViewFactoryProtocol {
    func expandView(isExpanded: Bool) -> some View {
        YoteiStripExpandDefaultView(isExpanded: isExpanded)
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

    func weekInteritemVerticalSpacing() -> CGFloat {
        8
    }
}
