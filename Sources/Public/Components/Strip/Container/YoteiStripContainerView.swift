//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripContainerView<ViewFactory: YoteiStripViewFactoryProtocol>: View {
    @Environment(\.calendar) private var calendar

    @Binding private var focusedDate: Date
    private let viewFactory: ViewFactory

    @State private var monthStripHeight: CGFloat = 0
    @State private var weekOffset: CGFloat = 0
    @State private var expandButtonHeight: CGFloat = 0
    @State private var dragEvent: DragEvent = .ended

    @State private var dragStartOpenProgress: CGFloat = 0
    @State private var openProgress: CGFloat = 0
    @State private var isWeekViewVisible = true

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
                    YoteiStripMonthView(
                        focusedDate: $focusedDate,
                        viewFactory: viewFactory
                    )
                    .offset(CGSize(
                        width: 0,
                        height: -weekOffset * (1 - openProgress)
                    ))

                    if isWeekViewVisible {
                        YoteiStripWeekView(
                            focusedDate: $focusedDate,
                            viewFactory: viewFactory
                        )
                        .frame(height: viewFactory.dayCellViewHeight())
                        .offset(CGSize(
                            width: 0,
                            height: weekOffset * openProgress
                        ))
                    }
                }
                .frame(height: maxMonthStripHeight, alignment: .top)
                .frame(height: frameHeight(), alignment: .top)
                .clipped()

                expandStripButton()
            }
            .parentView { (view: UIScrollView) in
                view.isScrollEnabled = false
                let gesture = DirectionalPanGestureRecognizer { event in
                    let prevEvent = dragEvent
                    dragEvent = event
                    switch event {
                    case .began:
                        dragStartOpenProgress = openProgress
                    case .changed:
                        calculateOpenProgress()
                    case .ended:
                        if case let .changed(_, _, velocity) = prevEvent {
                            let target: CGFloat = velocity.y > 0 ? 1 : 0
                            let diffHeight = monthStripHeight - viewFactory.dayCellViewHeight()
                            let remainingDistance = abs(target - openProgress) * diffHeight
                            let speed = abs(velocity.y)

                            // time to cover the remaining distance at the current finger speed,
                            // clamped so a tiny/huge fling still feels reasonable
                            let duration = speed > 0
                                ? min(max(Double(remainingDistance / speed), 0.15), 0.5)
                                : 0.35

                            isWeekViewVisible = velocity.y <= 0
                            withAnimation(.easeOut(duration: duration)) {
                                openProgress = target
                            }
                        }
                    }
                }
                view.addGestureRecognizer(gesture)
            }
        }
        .frame(height: frameHeight() + expandButtonHeight, alignment: .top)
        .background(.background)
        .onAppear {
            recalculateLayout()
        }
        .onChange(of: focusedDate) { _ in
            // simultaneous UIPageController page switch animation and size change animation breaks page switching and leads to unpredictable behavour,
            // animation delay serialize the animations and fixes the problem
            withAnimation(.default.delay(0.3)) {
                recalculateLayout()
            }
        }
        .zIndex(10)
    }
}

private extension YoteiStripContainerView {
    func frameHeight() -> CGFloat {
        let minHeight = viewFactory.dayCellViewHeight()
        let maxHeight = monthStripHeight
        let diffHeight = maxHeight - minHeight
        return minHeight + diffHeight * openProgress
    }

    func calculateOpenProgress() {
        let minHeight = viewFactory.dayCellViewHeight()
        let maxHeight = monthStripHeight
        let diffHeight = maxHeight - minHeight
        var currentDiffHeight = diffHeight * dragStartOpenProgress

        if case let .changed(translation, _, _) = dragEvent {
            currentDiffHeight += translation.y
        }

        openProgress = min(max(currentDiffHeight / diffHeight, 0), 1)
    }

    /// Recomputes the calendar-derived layout values that depend on `focusedDate`.
    /// Caching them into @State keeps every drag/animation frame — which only
    /// changes `openProgress` — free of calendar math.
    func recalculateLayout() {
        let numberOfWeeks = CGFloat(calendar.range(
            of: .weekOfMonth,
            in: .month,
            for: focusedDate
        )!.count)
        monthStripHeight = viewFactory.dayCellViewHeight() * numberOfWeeks + viewFactory.weekInteritemVerticalSpacing() * (numberOfWeeks - 1)

        let week = focusedDate.weekOfMonth(in: calendar)
        weekOffset = CGFloat(week) * (viewFactory.dayCellViewHeight() + viewFactory.weekInteritemVerticalSpacing())
    }

    func expandStripButton() -> some View {
        viewFactory.expandView(progress: openProgress)
            .onGeometryChange(for: CGFloat.self, of: {
                $0.size.height
            }) {
                expandButtonHeight = $0
            }
            .onTapGesture {
                isWeekViewVisible = openProgress > 0
                withAnimation {
                    openProgress = openProgress > 0 ? 0 : 1
                }
            }
    }
}
