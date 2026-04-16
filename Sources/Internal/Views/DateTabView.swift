//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct DateTabView<Content: View>: UIViewControllerRepresentable {
    @Binding private var selection: Date
    @ViewBuilder private let content: (Date) -> Content
    private let previousDate: (Date) -> Date
    private let nextDate: (Date) -> Date

    init(
        selection: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Content,
        previousDate: @escaping (Date) -> Date,
        nextDate: @escaping (Date) -> Date
    ) {
        _selection = selection
        self.content = content
        self.previousDate = previousDate
        self.nextDate = nextDate
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
        guard context.coordinator.currentPageDate != selection else {
            uiViewController.viewControllers?.compactMap {
                $0 as? PageController
            }.forEach {
                $0.rootView = content($0.date)
            }
            return
        }

        uiViewController.setViewControllers(
            [PageController(date: selection, content: content(selection))],
            direction: context.coordinator.currentPageDate < selection ? .forward : .reverse,
            animated: true
        )
        context.coordinator.currentPageDate = selection
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            selection: $selection,
            content: content,
            previousDate: previousDate,
            nextDate: nextDate
        )
    }
}

extension DateTabView {
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        @Binding private var selection: Date
        private let content: (Date) -> Content
        private let previousDate: (Date) -> Date
        private let nextDate: (Date) -> Date

        var currentPageDate: Date

        init(
            selection: Binding<Date>,
            @ViewBuilder content: @escaping (Date) -> Content,
            previousDate: @escaping (Date) -> Date,
            nextDate: @escaping (Date) -> Date
        ) {
            _selection = selection
            self.content = content
            self.previousDate = previousDate
            self.nextDate = nextDate

            currentPageDate = selection.wrappedValue
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = previousDate(pageController.date)
            return PageController(date: date, content: content(date))
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = nextDate(pageController.date)
            return PageController(date: date, content: content(date))
        }

        func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            pendingViewControllers.compactMap {
                $0 as? PageController
            }.forEach {
                $0.rootView = content($0.date)
            }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating _: Bool,
            previousViewControllers _: [UIViewController],
            transitionCompleted _: Bool
        ) {
            guard let pageController = pageViewController.viewControllers?.first as? PageController else {
                return
            }
            DispatchQueue.main.async {
                guard self.selection != pageController.date else {
                    return
                }
                self.currentPageDate = pageController.date
                self.selection = pageController.date
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
