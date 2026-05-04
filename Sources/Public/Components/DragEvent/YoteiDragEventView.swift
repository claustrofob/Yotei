//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import SwiftUI

public struct YoteiDragEventView<
    ViewFactory: YoteiDragEventViewFactoryProtocol,
    Content: View,
    Data: YoteiEventData
>: View where ViewFactory.Data == Data {
    @Binding private var data: YoteiEventsInterval<Data>
    @Binding private var contentOffset: CGPoint?
    @Binding private var focusedDate: Date
    @ViewBuilder private let content: () -> Content
    private let viewFactory: ViewFactory

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        viewFactory: ViewFactory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _data = data
        _contentOffset = contentOffset
        _focusedDate = focusedDate
        self.viewFactory = viewFactory
        self.content = content
    }

    public init(
        data: Binding<YoteiEventsInterval<Data>>,
        contentOffset: Binding<CGPoint?>,
        focusedDate: Binding<Date>,
        @ViewBuilder content: @escaping () -> Content
    ) where ViewFactory == YoteiDragEventViewFactory<Data> {
        self.init(
            data: data,
            contentOffset: contentOffset,
            focusedDate: focusedDate,
            viewFactory: YoteiDragEventViewFactory(),
            content: content
        )
    }

    public var body: some View {
        ContainerView(
            data: $data,
            contentOffset: $contentOffset,
            focusedDate: $focusedDate,
            viewFactory: viewFactory,
            content: content
        )
        .ignoresSafeArea()
    }
}
