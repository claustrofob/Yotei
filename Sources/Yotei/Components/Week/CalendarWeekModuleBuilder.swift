import Foundation
import SwiftUI

struct CalendarWeekModuleBuilder {
    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarWeekModuleView(focusedDate: focusedDate)
    }
}
