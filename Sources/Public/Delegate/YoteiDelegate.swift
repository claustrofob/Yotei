//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public protocol YoteiDelegate<Data>: AnyObject {
    associatedtype Data: YoteiEventData

    func calendarDidSelectEvent(with id: YoteiEvent<Data>.ID)
    func calendarDidSelectAllDay(date: Date)
    func calendarDidSelect(dateInterval: DateInterval, completion: () -> Void)
    func calendarDidSelectMonthDay(date: Date)
    func calendarDidUpdate(event: YoteiEvent<Data>)
}

public enum YoteiDelegateKey: EnvironmentKey {
    public nonisolated(unsafe) static let defaultValue: (any YoteiDelegate)? = nil
}

public extension EnvironmentValues {
    var yoteiDelegate: (any YoteiDelegate)? {
        get {
            self[YoteiDelegateKey.self]
        } set {
            self[YoteiDelegateKey.self] = newValue
        }
    }
}

public extension View {
    func yoteiDelegate(_ delegate: (any YoteiDelegate)?) -> some View {
        environment(\.yoteiDelegate, delegate)
    }
}
