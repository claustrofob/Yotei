import SwiftUI

struct CalendarScheduleModuleCollectionViewLoadingCell: View {
    var body: some View {
        RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
            .themeFill(.base20)
            .opacity(0.5)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 8, trailing: 0))
    }
}
