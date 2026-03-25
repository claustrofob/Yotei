import SwiftUI

struct CalendarDayEventsModuleEventPlaceholderView: View {
    private enum Constants {
        static var paddingCoefficient: CGFloat { 0.033 }
    }

    @Environment(\.theme) private var theme

    let coordinateSpace: CoordinateSpace

    var body: some View {
        GeometryReader { proxy in
            let indicatorPadding: CGFloat = Constants.paddingCoefficient * proxy.size.width
            RoundedRectangle(cornerSize: .init(width: 4, height: 4))
                .themeStroke(.brandPrimary40, lineWidth: 2)
                .overlay(alignment: .topTrailing) {
                    dragIndicator()
                        .alignmentGuide(.top) { $0.height / 2 }
                        .alignmentGuide(.trailing) { $0.width / 2 + indicatorPadding }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(coordinateSpace: coordinateSpace).onChanged { _ in
                            // TODO: implement drag
                        })
                }
                .overlay(alignment: .bottomLeading) {
                    dragIndicator()
                        .alignmentGuide(.bottom) { $0.height / 2 }
                        .alignmentGuide(.leading) { $0.width / 2 - indicatorPadding }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(coordinateSpace: coordinateSpace).onChanged { _ in
                            // TODO: implement drag
                        })
                }
                .contentShape(Rectangle())
        }
    }

    private func dragIndicator() -> some View {
        Circle()
            .stroke(theme.palette.brandPrimary10.suColor, lineWidth: 2)
            .background(Circle().foregroundColor(theme.palette.brandPrimary40.suColor))
            .frame(width: 10, height: 10)
    }
}
