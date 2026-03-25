import SwiftUI

struct CalendarDayEventsModuleEventView: View {
    @Environment(\.theme) private var theme

    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .foregroundStyle(theme.palette.brandSecondary70.suColor)
                .themeFont(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 16)
                .padding(.horizontal, 4)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(theme.palette.brandSecondary60.suColor.opacity(0.2))
        .cornerRadius(4)
    }
}
