//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI
import Yotei

struct DayEventsViewFactory: YoteiDayEventsViewFactoryProtocol {
    let colors: [Color] = [.red, .blue, .yellow, .green, .purple]

    func timeSlotView(date: Date) -> some View {
        DayEventsTimeSlotView(date: date)
    }

    func eventView(event: YoteiEvent<EventData>) -> some View {
        let index = abs(event.id.hashValue) % colors.count
        let color = colors[index]

        return YoteiDayEventsViewFactory().eventView(event: event)
            .tint(color)
            .backgroundStyle(color.complementary)
    }
}

private extension Color {
    var complementary: Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(
            hue: (h + 0.5).truncatingRemainder(dividingBy: 1.0),
            saturation: s,
            brightness: b,
            opacity: a
        )
    }
}
