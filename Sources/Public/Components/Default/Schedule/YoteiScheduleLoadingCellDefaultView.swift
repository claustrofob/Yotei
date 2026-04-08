//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiScheduleLoadingCellDefaultView: View {
    public init() {}

    public var body: some View {
        RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
            .fill(.quinary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 8, trailing: 0))
    }
}
