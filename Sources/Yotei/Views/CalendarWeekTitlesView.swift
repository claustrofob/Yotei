import SwiftUI

struct CalendarWeekTitlesView: View {
    let spacing: CGFloat

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Calendar.current.weekdayIndices, id: \.self) { index in
                Text("\(Calendar.current.veryShortStandaloneWeekdaySymbols[index - 1])")
                    .frame(maxWidth: .infinity)
                    .themeFont(.subcaption)
                    .themeForegroundStyle(.base80)
            }
        }
        .frame(height: 24)
    }
}
