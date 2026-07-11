//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiStripExpandDefaultView: View {
    @Binding private var isExpanded: Bool

    public init(isExpanded: Binding<Bool>) {
        _isExpanded = isExpanded
    }

    public var body: some View {
        Capsule()
            .fill(.tertiary)
            .frame(width: 36, height: 5)
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .contentShape(Rectangle())
    }
}
