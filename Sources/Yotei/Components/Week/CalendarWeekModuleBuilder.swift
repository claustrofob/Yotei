import Foundation
import SwiftUI
import Swinject

struct CalendarWeekModuleBuilder {
    @ViewBuilder
    func view(focusedDate: Binding<Date>) -> some View {
        CalendarWeekModuleView(focusedDate: focusedDate)
    }
}
