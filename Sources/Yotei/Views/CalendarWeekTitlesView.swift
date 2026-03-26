import SwiftUI

struct CalendarWeekTitlesView: View {
    let spacing: CGFloat

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Calendar.current.weekdayIndices, id: \.self) { index in
                Text("\(Calendar.current.veryShortStandaloneWeekdaySymbols[index - 1])")
                    .frame(maxWidth: .infinity)
                    .font(.system(.caption))
                    .foregroundStyle(.black.opacity(0.2))
            }
        }
        .frame(height: 24)
    }
}
