import Media
import SwiftUI
import Themes

struct CalendarDayCellView: View {
    private typealias CellStyle = (
        backgroundColor: Color,
        foregroundColor: BackgroundColorStyle,
        isEventsVisible: Bool
    )

    @Environment(\.theme) private var theme

    private let dayFormatStyle: Date.FormatStyle
    private let date: Date
    private let todayDate: Date
    private let focusedDate: Date?
    private let isEnabled: Bool
    private let calendar: Calendar

    init(
        date: Date,
        todayDate: Date,
        focusedDate: Date? = nil,
        isEnabled: Bool = true,
        calendar: Calendar = .current
    ) {
        self.date = date
        self.todayDate = todayDate
        self.focusedDate = focusedDate
        self.isEnabled = isEnabled
        self.calendar = calendar
        dayFormatStyle = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day()
    }

    var body: some View {
        let style = dayStyle(date: date)
        Text(date.formatted(dayFormatStyle))
            .themeFont(.subhead2)
            .themeForegroundStyle(style.foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: 40)
            .background {
                Circle().fill(style.backgroundColor)
            }
    }

    private func dayStyle(date: Date) -> CellStyle {
        if date.isInSameDay(as: todayDate) {
            (Color(uiColor: theme.palette.brandPrimary40), .addition50, false)
        } else if !isEnabled {
            (.clear, .base80, false)
        } else if let focusedDate, date.isInSameDay(as: focusedDate) {
            (Color(uiColor: theme.palette.brandPrimary10), .brandPrimary40, false)
        } else {
            (.clear, .base110, true)
        }
    }
}
