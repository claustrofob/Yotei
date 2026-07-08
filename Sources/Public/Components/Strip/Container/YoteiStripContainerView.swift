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
    @State private var isExpanded = false
    @State private var expandButtonHeight: CGFloat = 0
    @State private var dragEvent: DragEvent = .ended
    @State private var frameHeight: CGFloat = 0
    @State private var animatedFrameHeight: CGFloat = 0

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
                    if
                        frameHeight > viewFactory.dayCellViewHeight()
                        || animatedFrameHeight > viewFactory.dayCellViewHeight()
                        || dragEvent.isActive
                    {
                        YoteiStripMonthView(
                            focusedDate: $focusedDate,
                            viewFactory: viewFactory
                        )
//                        .offset(CGSize(
//                            width: 0,
//                            height: isExpanded ? -weekOffset() : weekOffset()
//                        ))
                        .zIndex(1)
                        .transition(.identity)
                    }

                    if !isExpanded {
                        YoteiStripWeekView(
                            focusedDate: $focusedDate,
                            viewFactory: viewFactory
                        )
                    }
                }
                .frame(height: maxMonthStripHeight, alignment: .top)
                .frame(height: frameHeight, alignment: .top)
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
                        ()
                    case .changed:
                        calculateFrameHeight()
                    case .ended:
                        switch prevEvent {
                        case let .changed(_, _, velocity):
                            withAnimation {
                                isExpanded = velocity.y > 0
                                calculateFrameHeight()
                            }
                        case .began, .ended:
                            ()
                        }
                    }
                }
                view.addGestureRecognizer(gesture)
            }
        }
        .animationCompletion(frameHeight, binding: $animatedFrameHeight)
        .frame(height: frameHeight + expandButtonHeight, alignment: .top)
        .background(.background)
        .onAppear {
            calculateMonthStripHeight()
            calculateFrameHeight()
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
    func calculateFrameHeight() {
        let minHeight = viewFactory.dayCellViewHeight()
        let maxHeight = monthStripHeight
        var height = isExpanded ? maxHeight : minHeight
        switch dragEvent {
        case let .changed(translation, _, _):
            height += translation.y
        case .began, .ended:
            ()
        }

        frameHeight = max(min(height, maxHeight), minHeight)
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
        viewFactory.expandView(isExpanded: isExpanded)
            .onGeometryChange(for: CGFloat.self, of: {
                $0.size.height
            }) {
                expandButtonHeight = $0
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                    calculateFrameHeight()
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
