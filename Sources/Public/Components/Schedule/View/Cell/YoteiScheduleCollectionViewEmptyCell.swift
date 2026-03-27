//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct YoteiScheduleCollectionViewEmptyCell: View {
    var body: some View {
        Text("No events")
            .font(.system(.subheadline))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}
