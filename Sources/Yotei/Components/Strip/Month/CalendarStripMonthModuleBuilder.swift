import Foundation
import SwiftUI

struct CalendarStripMonthModuleBuilder {
    let date: Date

    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripMonthModuleView(focusedDate: focusedDate, date: date)
            .id(date)
    }
}
