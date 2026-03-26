import Foundation
import SwiftUI

@MainActor
struct CalendarWeekModuleBuilder {
    @ViewBuilder
    func view(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) -> some View {
        CalendarWeekModuleView(
            focusedDate: focusedDate,
            data: data,
            delegate: delegate
        )
    }
}
