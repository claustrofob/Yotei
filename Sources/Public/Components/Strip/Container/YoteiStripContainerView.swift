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

    public init(
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory = YoteiStripViewFactory()
    ) {
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
    }

    public var body: some View {
        MainView(
            focusedDate: $focusedDate,
            viewFactory: viewFactory,
            initialWeekPageDate: calendar.dateInterval(
                of: .weekOfMonth,
                for: focusedDate
            )!.start,
            initialMonthPageDate: calendar.dateInterval(
                of: .month,
                for: focusedDate
            )!.start
        )
    }
}

private extension YoteiStripContainerView {
    struct MainView: View {
        @Environment(\.calendar) private var calendar

        @Binding var focusedDate: Date
        let viewFactory: ViewFactory

        @State var selectedWeekPageDate: Date
        @State var selectedMonthPageDate: Date

        @State private var monthStripHeight: CGFloat = 0
        @State private var expandDragStarted = false
        @State private var isExpanded = false
        @State private var expandButtonHeight: CGFloat = 0

        private var maxMonthStripHeight: CGFloat {
            viewFactory.dayCellViewHeight() * 6 + viewFactory.weekInteritemVerticalSpacing() * 5
        }

        init(
            focusedDate: Binding<Date>,
            viewFactory: ViewFactory,
            initialWeekPageDate: Date,
            initialMonthPageDate: Date
        ) {
            _focusedDate = focusedDate
            self.viewFactory = viewFactory
            selectedWeekPageDate = initialWeekPageDate
            selectedMonthPageDate = initialMonthPageDate
        }

        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // On iOS17 scroll view area of PageController extends beyond the container edges.
                    // This extra ScrollView fixes it.
                    ScrollView(.vertical) {
                        ZStack(alignment: .top) {
                            Group {
                                if isExpanded {
                                    tabView(selection: $selectedMonthPageDate, component: .month) { date in
                                        YoteiStripMonthView(
                                            focusedDate: $focusedDate,
                                            date: date,
                                            viewFactory: viewFactory
                                        )
                                        .frame(maxHeight: .infinity, alignment: .top)
                                        .animation(.default, value: focusedDate)
                                        .ignoresSafeArea(edges: .all)
                                    }
                                    .zIndex(1)
                                } else {
                                    tabView(selection: $selectedWeekPageDate, component: .weekOfMonth) { date in
                                        YoteiStripWeekView(
                                            focusedDate: $focusedDate,
                                            date: date,
                                            viewFactory: viewFactory
                                        )
                                        .frame(maxHeight: .infinity, alignment: .top)
                                        .animation(.default, value: focusedDate)
                                        .ignoresSafeArea(edges: .all)
                                    }
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
                        // this frame is required for transition to work properly
                        .frame(height: maxMonthStripHeight, alignment: .top)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollDisabled(true)
                    .frame(height: isExpanded ? monthStripHeight : viewFactory.dayCellViewHeight(), alignment: .top)
                    .clipped()
                    .contentShape(Rectangle())

                    expandStripButton()

                    // cover the rest of the screen
                    if isExpanded {
                        PassthroughTouchDetectorView {
                            withAnimation {
                                viewDidSelectCollapse()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        // it must cover the rest of the screen
                        .frame(height: 3000)
                    }
                }
                .frame(height: viewFactory.dayCellViewHeight() + expandButtonHeight, alignment: .top)
            }
            .onAppear {
                generateSelectedWeekPageDate()
                generateSelectedMonthPageDate()
                calculateMonthStripHeight()
            }
            .onChange(of: selectedWeekPageDate) { _ in
                updateSelectedPageDate()
                calculateMonthStripHeight()
            }
            .onChange(of: selectedMonthPageDate) { _ in
                updateSelectedPageDate()
                calculateMonthStripHeight()
            }
            .onChange(of: focusedDate) { _ in
                generateSelectedWeekPageDate()
                generateSelectedMonthPageDate()
            }
            .simultaneousGesture(DragGesture().onChanged { value in
                guard !expandDragStarted else {
                    return
                }
                expandDragStarted = true

                guard abs(value.translation.height) > abs(value.translation.width) else {
                    return
                }

                withAnimation {
                    value.translation.height > 0
                        ? viewDidSelectExpand()
                        : viewDidSelectCollapse()
                }
            }.onEnded { _ in
                expandDragStarted = false
            })
            .animation(.default, value: monthStripHeight)
            .zIndex(10)
        }

        func tabView(
            selection: Binding<Date>,
            component: Calendar.Component,
            content: @escaping (Date) -> some View
        ) -> some View {
            DateTabView(
                selection: selection,
                content: { date in
                    content(date)
                        // Keep the navigation bar explicitly visible
                        // This view is hosted inside a UIPageViewController, and during some
                        // page transitions the navigation bar may be hidden unexpectedly
                        .toolbar(.visible, for: .navigationBar)
                },
                previousDate: { date in
                    calendar.date(
                        byAdding: component,
                        value: -1,
                        to: date
                    )!
                },
                nextDate: { date in
                    calendar.date(
                        byAdding: component,
                        value: 1,
                        to: date
                    )!
                }
            )
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
                        generateSelectedWeekPageDate()
                        generateSelectedMonthPageDate()
                    }
                }
        }

        func generateSelectedWeekPageDate() {
            let startDate = calendar.dateInterval(
                of: .weekOfMonth,
                for: focusedDate
            )!.start

            guard startDate != selectedWeekPageDate else {
                return
            }
            selectedWeekPageDate = startDate
        }

        func generateSelectedMonthPageDate() {
            let startDate = calendar.dateInterval(
                of: .month,
                for: focusedDate
            )!.start

            guard startDate != selectedMonthPageDate else {
                return
            }
            selectedMonthPageDate = startDate
        }

        func updateSelectedPageDate() {
            let calendarDateService = DateService(calendar: calendar)
            focusedDate = isExpanded
                ? calendarDateService.monthFocusedDate(for: selectedMonthPageDate, currentFocusedDate: focusedDate)
                : calendarDateService.weekFocusedDate(for: selectedWeekPageDate, currentFocusedDate: focusedDate)
        }

        func viewDidSelectExpand() {
            guard !isExpanded else {
                return
            }
            isExpanded = true
            generateSelectedWeekPageDate()
            generateSelectedMonthPageDate()
        }

        func viewDidSelectCollapse() {
            guard isExpanded else {
                return
            }
            isExpanded = false
            generateSelectedWeekPageDate()
            generateSelectedMonthPageDate()
        }
    }
}
