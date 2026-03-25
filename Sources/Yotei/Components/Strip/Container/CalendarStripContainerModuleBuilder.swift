import Foundation
import SwiftUI

struct CalendarStripContainerModuleBuilder {
    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripContainerModuleView(focusedDate: focusedDate)
    }
}
