import Foundation
import SwiftUI

struct CalendarAllDayEventsTopModuleBuilder {
    private struct Input: Hashable {
        let startDate: Date
        let numberOfDays: Int
    }

    private let input: Input

    init(startDate: Date, numberOfDays: Int) {
        input = Input(startDate: startDate, numberOfDays: numberOfDays)
    }

    @ViewBuilder
    func view(data: Binding<CalendarEventsInterval>, delegate: CalendarDelegate?) -> some View {
        CalendarAllDayEventsTopModuleView(
            startDate: input.startDate,
            numberOfDays: input.numberOfDays,
            data: data,
            delegate: delegate
        )
        .id(input)
    }
}
