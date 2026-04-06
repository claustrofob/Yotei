//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public protocol YoteiScheduleViewFactoryProtocol {
    associatedtype EventCellView: View
    func eventCellView(date: Date, event: YoteiEvent) -> EventCellView

    associatedtype EmptyCellView: View
    func emptyCellView(date: Date) -> EmptyCellView

    associatedtype LoadingCellView: View
    func loadingCellView(date: Date) -> LoadingCellView

    associatedtype DayHeaderView: View
    func dayHeaderView(date: Date) -> DayHeaderView

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize
    func emptyViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func loadingViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize
    func headerViewSizeThatFits(proposal: ProposedViewSize, date: Date) -> CGSize

    func insetsForHeader() -> UIEdgeInsets
    func headerLineSpacing() -> CGFloat
    func interitemSpacing() -> CGFloat
}
