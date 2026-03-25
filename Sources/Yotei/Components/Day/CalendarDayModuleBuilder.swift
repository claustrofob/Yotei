import Foundation
import SwiftUI

struct CalendarDayModuleBuilder {
    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarDayModuleView(focusedDate: focusedDate)
    }
}
