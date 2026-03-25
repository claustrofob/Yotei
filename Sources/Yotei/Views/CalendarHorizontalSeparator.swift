import Foundation
import SwiftUI

struct CalendarHorizontalSeparator: View {
    @Environment(\.theme) private var theme

    var body: some View {
        theme.palette.base20.suColor
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
