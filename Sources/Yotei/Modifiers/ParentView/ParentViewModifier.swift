import SwiftUI

struct ParentViewModifier<ViewType: UIView>: ViewModifier {
    let completion: (ViewType) -> Void

    func body(content: Content) -> some View {
        content
            .background {
                ParentViewRepresentable(completion: completion)
            }
    }
}

extension View {
    func parentView<ViewType: UIView>(completion: @escaping (ViewType) -> Void) -> some View {
        return modifier(ParentViewModifier(completion: completion))
    }
}
