//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripMonthView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    public init(
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
    }

    public var body: some View {
        DateTabView(
            selection: $focusedDate,
            component: .month,
            content: { date in
                YoteiStripMonthPageView(
                    focusedDate: $focusedDate,
                    date: date,
                    viewFactory: viewFactory
                )
                .frame(maxHeight: .infinity, alignment: .top)
                .animation(.default, value: focusedDate)
                .ignoresSafeArea(edges: .all)
                // Keep the navigation bar explicitly visible
                // This view is hosted inside a UIPageViewController, and during some
                // page transitions the navigation bar may be hidden unexpectedly
                .toolbar(.visible, for: .navigationBar)
            }
        )
    }
}
