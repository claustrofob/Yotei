//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

struct TimezoneSelectorView: View {
    @Binding var timezone: String?
    @State var timezones = [TimeZone]()

    var body: some View {
        List(selection: $timezone) {
            ForEach(timezones, id: \.identifier) { timezone in
                HStack {
                    Text(timezone.identifier)
                    Spacer()

                    let hours = timezone.secondsFromGMT() / 3600
                    let minutes = abs(timezone.secondsFromGMT() % 3600) / 60
                    Text(String(format: "UTC%+03d:%02d", hours, minutes))
                }
            }
        }
        .task {
            timezones = TimeZone.knownTimeZoneIdentifiers
                .compactMap { TimeZone(identifier: $0) }
                .sorted { $0.secondsFromGMT() < $1.secondsFromGMT() }
        }
    }
}
