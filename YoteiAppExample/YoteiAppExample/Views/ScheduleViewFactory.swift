//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct ScheduleViewFactory: YoteiScheduleViewFactoryProtocol {
    private enum Constants {
        static var sectionInsets: UIEdgeInsets {
            .init(top: 6, left: 16, bottom: 8, right: 16)
        }
    }

    func eventCellView(date: Date, event: YoteiEvent) -> some View {
        YoteiScheduleEventCellDefaultView(cellDate: date, event: event)
    }

    func emptyCellView(date _: Date) -> some View {
        YoteiScheduleEmptyCellDefaultView()
    }

    func loadingCellView(date _: Date) -> some View {
        YoteiScheduleLoadingCellDefaultView()
    }

    func dayHeaderView(date: Date) -> some View {
        YoteiScheduleSectionHeaderDefaultView(date: date)
    }

    func eventViewSizeThatFits(proposal: ProposedViewSize, event: YoteiEvent) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - Constants.sectionInsets.left - Constants.sectionInsets.right
        return CGSize(width: width, height: event.isAllDay ? 16 : 52)
    }

    func emptyViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - Constants.sectionInsets.left - Constants.sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func loadingViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let width = size.width - Constants.sectionInsets.left - Constants.sectionInsets.right
        return CGSize(width: width, height: 52)
    }

    func headerViewSizeThatFits(proposal: ProposedViewSize, date _: Date) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        return CGSize(width: size.width, height: 28)
    }

    func insetsForHeader() -> UIEdgeInsets {
        Constants.sectionInsets
    }

    func headerLineSpacing() -> CGFloat {
        8
    }

    func interitemSpacing() -> CGFloat {
        8
    }
}
