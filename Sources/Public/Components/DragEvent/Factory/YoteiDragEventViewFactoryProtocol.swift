//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

@MainActor
public protocol YoteiDragEventViewFactoryProtocol<Data> {
    associatedtype Data: YoteiEventData

    associatedtype EventView: View
    func eventView(event: YoteiEvent<Data>) -> EventView
    func snapToMinutes() -> Int
}

public extension YoteiDragEventViewFactoryProtocol {
    func eventView(event: YoteiEvent<Data>) -> some View {
        YoteiDayDragEventDefaultView(event: event)
    }

    func snapToMinutes() -> Int {
        15
    }
}
