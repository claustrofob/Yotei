//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

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
    func onChange(
        of value: some Equatable,
        initial: Bool,
        isAsync: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(OnChangeModifier(
            value: value,
            initial: initial,
            action: {
                if isAsync {
                    DispatchQueue.main.async {
                        action()
                    }
                } else {
                    action()
                }
            }
        ))
    }
}
