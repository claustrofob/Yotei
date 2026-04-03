//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripContainerView: View {
    private struct DummyModifier: ViewModifier {
        let isActive: Bool

        func body(content: Content) -> some View {
            content.padding(.bottom, isActive ? 1 : 0)
        }
    }

    private enum Constants {
        static var expandButtonHeight: CGFloat { 24 }
        static var weekStripHeight: CGFloat { 40 }
        static var weekStripVPadding: CGFloat { 8 }
        static var maxMonthStripHeight: CGFloat {
            weekStripHeight * 6 + weekStripVPadding * 5
        }
    }

    private let calendarDateService = CalendarDateService()

    @State private var monthStripHeight: CGFloat = 0
    @State private var expandDragStarted = false
    @State private var selectedWeekPageDate: Date
    @State private var selectedMonthPageDate: Date
    @State private var isExpanded = false

    @Binding private var focusedDate: Date

    public init(focusedDate: Binding<Date>) {
        _focusedDate = focusedDate
        selectedWeekPageDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: focusedDate.wrappedValue
        )!.start
        selectedMonthPageDate = Calendar.current.dateInterval(
            of: .month,
            for: focusedDate.wrappedValue
        )!.start
    }

    public var body: some View {
        VStack(spacing: 0) {
            CalendarWeekTitlesView(spacing: 10)

            VStack(spacing: 0) {
                // On iOS17 scroll view area of PageController extends beyond the container edges.
                // This extra ScrollView fixes it.
                ScrollView(.vertical) {
                    ZStack(alignment: .top) {
                        Group {
                            if isExpanded {
                                tabView(selection: $selectedMonthPageDate, component: .month) { date in
                                    YoteiStripMonthView(focusedDate: $focusedDate, date: date)
                                        .frame(maxHeight: .infinity, alignment: .top)
                                        .animation(.default, value: focusedDate)
                                        .ignoresSafeArea(edges: .all)
                                }
                                .zIndex(1)
                            } else {
                                tabView(selection: $selectedWeekPageDate, component: .weekOfMonth) { date in
                                    YoteiStripWeekView(focusedDate: $focusedDate, date: date)
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
                    .frame(height: Constants.maxMonthStripHeight, alignment: .top)
                    .frame(maxWidth: .infinity)
                }
                .scrollDisabled(true)
                .frame(height: isExpanded ? monthStripHeight : Constants.weekStripHeight, alignment: .top)
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
            .frame(height: Constants.weekStripHeight + Constants.expandButtonHeight, alignment: .top)
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
}

private extension YoteiStripContainerView {
    func tabView(
        selection: Binding<Date>,
        component: Calendar.Component,
        content: @escaping (Date) -> some View
    ) -> some View {
        CalendarTabView(
            selection: selection,
            content: { date in
                content(date)
                    // Keep the navigation bar explicitly visible
                    // This view is hosted inside a UIPageViewController, and during some
                    // page transitions the navigation bar may be hidden unexpectedly
                    .toolbar(.visible, for: .navigationBar)
            },
            previousDate: { date in
                Calendar.current.date(
                    byAdding: component,
                    value: -1,
                    to: date
                )!
            },
            nextDate: { date in
                Calendar.current.date(
                    byAdding: component,
                    value: 1,
                    to: date
                )!
            }
        )
    }

    func calculateMonthStripHeight() {
        let numberOfWeeks = CGFloat(Calendar.current.range(
            of: .weekOfMonth,
            in: .month,
            for: focusedDate
        )!.count)
        monthStripHeight = Constants.weekStripHeight * numberOfWeeks + Constants.weekStripVPadding * (numberOfWeeks - 1)
    }

    func weekOffset() -> CGFloat {
        let week = focusedDate.weekOfMonth(in: .current)
        return CGFloat(week) * (Constants.weekStripHeight + Constants.weekStripVPadding)
    }

    func expandStripButton() -> some View {
        Image(systemName: "chevron.compact.down")
            .tint(.black)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .contentShape(Rectangle())
            .background(.background)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                    generateSelectedWeekPageDate()
                    generateSelectedMonthPageDate()
                }
            }
    }

    func generateSelectedWeekPageDate() {
        let startDate = Calendar.current.dateInterval(
            of: .weekOfMonth,
            for: focusedDate
        )!.start

        guard startDate != selectedWeekPageDate else {
            return
        }
        selectedWeekPageDate = startDate
    }

    func generateSelectedMonthPageDate() {
        let startDate = Calendar.current.dateInterval(
            of: .month,
            for: focusedDate
        )!.start

        guard startDate != selectedMonthPageDate else {
            return
        }
        selectedMonthPageDate = startDate
    }

    func updateSelectedPageDate() {
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
