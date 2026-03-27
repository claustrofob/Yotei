import SwiftUI

struct CalendarDayEventsEventView: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .foregroundStyle(.blue.opacity(0.5))
                .font(.system(.caption2))
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
        .background(.blue.opacity(0.2))
        .cornerRadius(4)
    }
}
