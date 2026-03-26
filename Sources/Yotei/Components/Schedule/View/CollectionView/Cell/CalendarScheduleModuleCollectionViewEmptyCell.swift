import SwiftUI

struct CalendarScheduleModuleCollectionViewEmptyCell: View {
    var body: some View {
        Text(String.localized_calendar_event_no_events)
            .font(.system(.subheadline))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}
