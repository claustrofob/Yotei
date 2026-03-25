import SwiftUI
import Themes

struct CalendarTabView<Content: View>: UIViewControllerRepresentable {
    @Binding var selection: Date
    @ViewBuilder let content: (Date) -> Content
    let previousDate: (Date) -> Date
    let nextDate: (Date) -> Date

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
        guard
            let pageController = uiViewController.viewControllers?.first as? PageController,
            pageController.date != selection
        else {
            uiViewController.viewControllers?.compactMap {
                $0 as? PageController
            }.forEach {
                $0.rootView = content($0.date)
            }
            return
        }
        // sometimes when prev animation not finished and a new vc is set, UIPageViewController gets broken
        // and does not render the final vc. Calling setViewControllers without animation for current vc seems to fix it.
        uiViewController.setViewControllers([pageController], direction: .forward, animated: false)
        uiViewController.setViewControllers(
            [PageController(date: selection, content: content(selection))],
            direction: pageController.date < selection ? .forward : .reverse,
            animated: true
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            content: content,
            previousDate: previousDate,
            nextDate: nextDate,
            onChange: { newDate in
                // Defer binding update to the next run loop tick
                // Updating it synchronously here can trigger:
                // "Publishing changes from within view updates is not allowed"
                DispatchQueue.main.async {
                    guard selection != newDate else {
                        return
                    }
                    selection = newDate
                }
            }
        )
    }
}

extension CalendarTabView {
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        private let content: (Date) -> Content
        private let previousDate: (Date) -> Date
        private let nextDate: (Date) -> Date
        private let onChange: (Date) -> Void

        init(
            @ViewBuilder content: @escaping (Date) -> Content,
            previousDate: @escaping (Date) -> Date,
            nextDate: @escaping (Date) -> Date,
            onChange: @escaping (Date) -> Void
        ) {
            self.content = content
            self.previousDate = previousDate
            self.nextDate = nextDate
            self.onChange = onChange
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = previousDate(pageController.date)
            return PageController(date: date, content: content(date))
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let pageController = viewController as? PageController else {
                return nil
            }
            let date = nextDate(pageController.date)
            return PageController(date: date, content: content(date))
        }

        func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            pendingViewControllers.compactMap {
                $0 as? PageController
            }.forEach {
                $0.rootView = content($0.date)
            }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard let pageController = pageViewController.viewControllers?.first as? PageController else {
                return
            }
            onChange(pageController.date)
        }
    }
}

extension CalendarTabView {
    final class PageController: UIHostingController<Content>, ThemeTrackable {
        let date: Date

        public var (themeLifetime, themeToken) = Lifetime.make()

        init(date: Date, content: Content) {
            self.date = date
            super.init(rootView: content)
            setupTheme()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func apply(_ theme: any ThemeProtocol) {
            view.backgroundColor = theme.palette.base0
        }
    }
}
