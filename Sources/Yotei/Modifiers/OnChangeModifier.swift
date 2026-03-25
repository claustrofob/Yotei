import SwiftUI

struct OnChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let initial: Bool
    let action: (Value, Value) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value, action)
            .onAppear {
                if initial {
                    action(value, value)
                }
            }
    }
}

extension View {
    func onChange<Value: Equatable>(
        of value: Value,
        initial: Bool,
        action: @escaping (Value, Value) -> Void
    ) -> some View {
        modifier(OnChangeModifier(value: value, initial: initial, action: action))
    }
}
