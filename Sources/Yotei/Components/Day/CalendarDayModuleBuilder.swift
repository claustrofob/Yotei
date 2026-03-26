import Foundation
import SwiftUI

@MainActor
struct CalendarDayModuleBuilder {
    @ViewBuilder
    func view(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) -> some View {
        CalendarDayModuleView(
            focusedDate: focusedDate,
            data: data,
            delegate: delegate
        )
    }
}
