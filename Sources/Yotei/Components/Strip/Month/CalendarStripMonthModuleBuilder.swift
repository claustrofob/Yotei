import Foundation
import SwiftUI

@MainActor
struct CalendarStripMonthModuleBuilder {
    let date: Date

    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripMonthModuleView(focusedDate: focusedDate, date: date)
            .id(date)
    }
}
