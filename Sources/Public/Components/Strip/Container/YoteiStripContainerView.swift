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
    @State private var expandButtonHeight: CGFloat = 0
    @State private var dragEvent: DragEvent = .ended

    @State private var dragStartOpenProgress: CGFloat = 0
    @State private var openProgress: CGFloat = 0

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
                        height: -weekOffset() * (1 - openProgress)
                    ))
                    .zIndex(1)
                    .transition(.identity)

                    YoteiStripWeekView(
                        focusedDate: $focusedDate,
                        viewFactory: viewFactory
                    )
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
                            withAnimation {
                                openProgress = velocity.y > 0 ? 1 : 0
                            }
                        }
                    }
                }
                view.addGestureRecognizer(gesture)
            }
        }
        // .animationCompletion(frameHeight, binding: $animatedFrameHeight)
        .frame(height: frameHeight() + expandButtonHeight, alignment: .top)
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
        viewFactory.expandView(progress: openProgress)
            .onGeometryChange(for: CGFloat.self, of: {
                $0.size.height
            }) {
                expandButtonHeight = $0
            }
            .onTapGesture {
                withAnimation {
                    openProgress = openProgress > 0 ? 0 : 1
                }
            }
    }
}

struct AnimationCompletion: ViewModifier, @MainActor Animatable {
    var progress: CGFloat
    @Binding var binding: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set {
            progress = newValue
            DispatchQueue.main.async { [self] in
                binding = newValue
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func animationCompletion(_ value: CGFloat, binding: Binding<CGFloat>) -> some View {
        modifier(AnimationCompletion(progress: value, binding: binding))
    }
}
