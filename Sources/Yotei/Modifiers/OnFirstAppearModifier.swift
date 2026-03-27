import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    let perform: () -> Void
    @State private var firstTime = true

    init(perform: @escaping () -> Void) {
        self.perform = perform
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if firstTime {
                firstTime = false
                perform()
            }
        }
    }
}

extension View {
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: perform))
    }
}
