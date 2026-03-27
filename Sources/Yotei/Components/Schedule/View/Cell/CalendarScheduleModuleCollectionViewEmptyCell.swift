import SwiftUI

struct CalendarScheduleModuleCollectionViewEmptyCell: View {
    var body: some View {
        Text("No events")
            .font(.system(.subheadline))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}
