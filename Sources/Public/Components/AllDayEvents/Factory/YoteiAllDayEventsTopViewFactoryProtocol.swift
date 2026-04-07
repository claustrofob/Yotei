//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiAllDayEventsTopViewFactoryProtocol {
    associatedtype EventView: View
    func eventView(event: YoteiEvent) -> EventView

    associatedtype MoreEventsView: View
    func moreEventsView(count: Int) -> MoreEventsView

    func insets() -> EdgeInsets
    func interitemVerticalSpacing() -> CGFloat
    func interitemHorizontalSpacing() -> CGFloat
}

public extension YoteiAllDayEventsTopViewFactoryProtocol {
    func eventView(event: YoteiEvent) -> some View {
        YoteiAllDayEventDefaultView(event: event)
    }

    func moreEventsView(count: Int) -> some View {
        YoteiAllDayMoreEventsDefaultView(moreEventsCount: count)
    }

    func insets() -> EdgeInsets {
        EdgeInsets(top: 4, leading: 0, bottom: 2, trailing: 0)
    }

    func interitemVerticalSpacing() -> CGFloat {
        2
    }

    func interitemHorizontalSpacing() -> CGFloat {
        0
    }
}
