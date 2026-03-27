//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

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
        modifier(ParentViewModifier(completion: completion))
    }
}
