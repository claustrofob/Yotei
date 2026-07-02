//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct OnChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let initial: Bool
    let action: (Value) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { value in
                action(value)
            }
            .onAppear {
                if initial {
                    action(value)
                }
            }
    }
}

extension View {
    func onChange<Value: Equatable>(
        of value: Value,
        initial: Bool,
        isAsync: Bool = false,
        action: @escaping (Value) -> Void
    ) -> some View {
        modifier(OnChangeModifier(
            value: value,
            initial: initial,
            action: { value in
                if isAsync {
                    DispatchQueue.main.async {
                        action(value)
                    }
                } else {
                    action(value)
                }
            }
        ))
    }
}
