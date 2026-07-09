//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

/// font styles that are currently used in default views
public struct YoteiFontStyle: Sendable {
    public var caption: Font
    public var caption2: Font
    public var body: Font
    public var headline: Font
    public var subheadline: Font

    public init(
        caption: Font = .caption,
        caption2: Font = .caption2,
        body: Font = .body,
        headline: Font = .headline,
        subheadline: Font = .subheadline
    ) {
        self.caption = caption
        self.caption2 = caption2
        self.body = body
        self.headline = headline
        self.subheadline = subheadline
    }
}

public extension EnvironmentValues {
    @Entry var yoteiFontStyle: YoteiFontStyle = .init()
}
