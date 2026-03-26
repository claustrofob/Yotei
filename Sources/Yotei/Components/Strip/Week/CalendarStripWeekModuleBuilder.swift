import Foundation
import SwiftUI

struct CalendarStripWeekModuleBuilder {
    let date: Date

    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripWeekModuleView(focusedDate: focusedDate, date: date)
            .id(date)
    }
}
