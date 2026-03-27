import SwiftUI

public struct CalendarHorizontalSeparator: View {
    public init() {}

    public var body: some View {
        Color.black.opacity(0.8)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}
