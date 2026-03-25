import Foundation
import SwiftUI

struct CalendarStripWeekModuleBuilder {
    let date: Date

    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarStripWeekModuleBuilder(focusedDate: focusedDate, date: date)
            .id(date)
    }
}
