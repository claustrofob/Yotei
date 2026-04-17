//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct DateTabView<Content: View>: UIViewControllerRepresentable {
    @Environment(\.calendar) private var calendar

    @Binding private var selection: Date
    @ViewBuilder private let content: (Date) -> Content
    private let component: Calendar.Component

    init(
        selection: Binding<Date>,
        component: Calendar.Component,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        _selection = selection
        self.component = component
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        vc.setViewControllers(
            [PageController(date: selection, content: content(selection))],
            direction: .forward,
            animated: false
        )

        return vc
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        context.coordinator.calendar = calendar
        context.coordinator.content = content
        context.coordinator.component = component

        let normalizedCurrentPageDate = calendar.dateInterval(
            of: component,
            for: context.coordinator.currentPageDate
        )!.start
        let normalizedSelection = calendar.dateInterval(
            of: component,
            for: selection
        )!.start

        guard normalizedCurrentPageDate != normalizedSelection else {
            context.coordinator.refresh(viewControllers: uiViewController.viewControllers ?? [])
            return
        }

        uiViewController.setViewControllers(
            [PageController(date: selection, content: content(selection))],
            direction: normalizedCurrentPageDate < normalizedSelection ? .forward : .reverse,
            animated: true
        )
        context.coordinator.currentPageDate = selection
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            selection: $selection,
            calendar: calendar,
            component: component,
            content: content
        )
    }
}

extension DateTabView {
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        @Binding private var selection: Date
        var calendar: Calendar
        var content: (Date) -> Content
        var component: Calendar.Component

        var currentPageDate: Date

        init(
            selection: Binding<Date>,
            calendar: Calendar,
            component: Calendar.Component,
            @ViewBuilder content: @escaping (Date) -> Content
        ) {
            _selection = selection
            self.calendar = calendar
            self.component = component
            self.content = content

            currentPageDate = selection.wrappedValue
        }

        private func nextDate(for date: Date, value: Int) -> Date {
            calendar.date(
                byAdding: component,
                value: value,
                to: date
            )!
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = nextDate(for: pageController.date, value: -1)
            return PageController(date: date, content: content(date))
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = nextDate(for: pageController.date, value: 1)
            return PageController(date: date, content: content(date))
        }

        func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            refresh(viewControllers: pendingViewControllers)
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted _: Bool
        ) {
            guard let pageController = pageViewController.viewControllers?.first as? PageController else {
                return
            }

            let normalizedCurrentPageDate = calendar.dateInterval(
                of: component,
                for: pageController.date
            )!.start
            let normalizedSelection = calendar.dateInterval(
                of: component,
                for: selection
            )!.start

            guard normalizedCurrentPageDate != normalizedSelection else {
                return
            }

            let value = normalizedCurrentPageDate < normalizedSelection ? -1 : 1
            let date = nextDate(for: selection, value: value)

            DispatchQueue.main.async {
                self.currentPageDate = date
                self.selection = date

                self.refresh(viewControllers: previousViewControllers)
            }
        }

        func refresh(viewControllers: [UIViewController]) {
            viewControllers.compactMap {
                $0 as? PageController
            }.forEach {
                $0.rootView = content($0.date)
            }
        }
    }
}

extension DateTabView {
    final class PageController: UIHostingController<Content> {
        let date: Date

        init(date: Date, content: Content) {
            self.date = date
            super.init(rootView: content)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
