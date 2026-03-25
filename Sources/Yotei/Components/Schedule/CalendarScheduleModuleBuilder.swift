import Foundation
import SwiftUI

struct CalendarScheduleModuleBuilder {
    @ViewBuilder
    func view(
        focusedDate: Binding<Date>,
        data: Binding<CalendarEventsInterval>,
        delegate: CalendarDelegate?
    ) -> some View {
        CalendarScheduleModuleView(
            focusedDate: focusedDate,
            data: data,
            delegate: delegate
        )
    }
}
