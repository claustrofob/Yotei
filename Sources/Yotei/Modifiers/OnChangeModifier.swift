import SwiftUI

struct OnChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let initial: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _ in
                action()
            }
            .onAppear {
                if initial {
                    action()
                }
            }
    }
}

extension View {
    func onChange<Value: Equatable>(
        of value: Value,
        initial: Bool,
        action: @escaping () -> Void
    ) -> some View {
        modifier(OnChangeModifier(value: value, initial: initial, action: action))
    }
}
