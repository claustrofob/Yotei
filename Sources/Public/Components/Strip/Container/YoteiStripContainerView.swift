//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripContainerView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    private struct DummyModifier: ViewModifier {
        let isActive: Bool

        func body(content: Content) -> some View {
            content.padding(.bottom, isActive ? 1 : 0)
        }
    }

    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    @State private var monthStripHeight: CGFloat = 0
    @State private var isExpanded = false
    @State private var expandDragStarted = false
    @State private var expandButtonHeight: CGFloat = 0

    private var maxMonthStripHeight: CGFloat {
        viewFactory.dayCellViewHeight() * 6 + viewFactory.weekInteritemVerticalSpacing() * 5
    }

    public init(
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Group {
                        if isExpanded {
                            YoteiStripMonthView(
                                focusedDate: $focusedDate,
                                viewFactory: viewFactory
                            )
                            .zIndex(1)
                        } else {
                            YoteiStripWeekView(
                                focusedDate: $focusedDate,
                                viewFactory: viewFactory
                            )
                        }
                    }
                    .transition(.offset(CGSize(
                        width: 0,
                        height: isExpanded ? -weekOffset() : weekOffset()
                    )).combined(with: .modifier(
                        // This transition is required for the case, when selected date is in the first week.
                        // In that case weekOffset() == 0, there is nothing to animate and old view immediately disappears at the start of animation.
                        // We have to always change something to trigger animation.
                        active: DummyModifier(isActive: true),
                        identity: DummyModifier(isActive: false)
                    )))
                }
                .frame(height: maxMonthStripHeight, alignment: .top)
                .frame(height: isExpanded ? monthStripHeight : viewFactory.dayCellViewHeight(), alignment: .top)
                .clipped()

                expandStripButton()
            }
            .parentView { (view: UIScrollView) in
                view.isScrollEnabled = false
                let gesture = DirectionalPanGestureRecognizer { event in
                    switch event {
                    case .began:
                        ()
                    case .changed(translation: let translation, location: _):
                        guard !expandDragStarted else {
                            return
                        }
                        expandDragStarted = true
                        withAnimation {
                            isExpanded = translation.y > 0
                        }
                    case .ended:
                        expandDragStarted = false
                    }
                }
                view.addGestureRecognizer(gesture)
            }
        }
        .frame(height: (isExpanded ? monthStripHeight : viewFactory.dayCellViewHeight()) + expandButtonHeight, alignment: .top)
        .background(.background)
        .onAppear {
            calculateMonthStripHeight()
        }
        .onChange(of: focusedDate) { _ in
            // simultaneous UIPageController page switch animation and size change animation breaks page switching and leads to unpredictable behavour,
            // animation delay serialize the animations and fixes the problem
            withAnimation(.default.delay(0.3)) {
                calculateMonthStripHeight()
            }
        }
        .zIndex(10)
    }
}

private extension YoteiStripContainerView {
    func calculateMonthStripHeight() {
        let numberOfWeeks = CGFloat(calendar.range(
            of: .weekOfMonth,
            in: .month,
            for: focusedDate
        )!.count)
        monthStripHeight = viewFactory.dayCellViewHeight() * numberOfWeeks + viewFactory.weekInteritemVerticalSpacing() * (numberOfWeeks - 1)
    }

    func weekOffset() -> CGFloat {
        let week = focusedDate.weekOfMonth(in: calendar)
        return CGFloat(week) * (viewFactory.dayCellViewHeight() + viewFactory.weekInteritemVerticalSpacing())
    }

    func expandStripButton() -> some View {
        viewFactory.expandView(isExpanded: $isExpanded)
            .onGeometryChange(for: CGFloat.self, of: {
                $0.size.height
            }) {
                expandButtonHeight = $0
            }
    }
}
