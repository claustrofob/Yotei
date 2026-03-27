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

public extension View {
    func onChange(
        of value: some Equatable,
        initial: Bool,
        action: @escaping () -> Void
    ) -> some View {
        modifier(OnChangeModifier(value: value, initial: initial, action: action))
    }
}
