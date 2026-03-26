import Foundation
import SwiftUI

@MainActor
struct CalendarStripContainerModuleBuilder {
    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripContainerModuleView(focusedDate: focusedDate)
    }
}
