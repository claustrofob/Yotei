# Yotei[^1]

[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016+-lightgrey.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A highly modular, highly customizable calendar package for iOS. Built with SwiftUI and UIKit under the hood for the best performance and native feel.

<p align="center">
    <img src="https://github.com/user-attachments/assets/5577be55-33ef-4660-bff1-df030423a137" width="256" height="256" alt="yotei-logo">
</p>

Every component can be used on its own or composed into a full calendar app. Pick only what you need — a date picker, a schedule list, a day timeline, an all-day grid — or wire them all together.

<img width="160" alt="yotei_demo" src="https://github.com/user-attachments/assets/1b624541-fbc4-4e53-bfc2-240a147dc7fe" />
<img width="160" alt="day_view" src="https://github.com/user-attachments/assets/e4c0838c-436d-48c4-93f0-803fc163282f" />
<img width="160" alt="week_view" src="https://github.com/user-attachments/assets/4397afb5-74e9-45f1-b694-494b84940def" />
<img width="160" alt="month_view" src="https://github.com/user-attachments/assets/ba5b8a4d-1221-4ce9-8ade-24a1e42d8a09" />
<img width="160" alt="schedule_view" src="https://github.com/user-attachments/assets/37eec48e-f59e-4620-ae99-fa4f5e4871d0" />

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Typed Event Data](#typed-event-data)
- [Colors Customization](#colors-customization)
- [Fonts Customization](#fonts-customization)
- [Customization with View Factories](#customization-with-view-factories)
- [Handling User Interaction](#handling-user-interaction)
- [Drag to Reschedule](#drag-to-reschedule)
- [Example App](#example-app)
- [Roadmap](#roadmap)
- [License](#license)

## Features

- **Composable by design.** Each view is an independent SwiftUI `View` — use one, use several, arrange them however your layout requires.
- **SwiftUI API, UIKit performance.** Heavy surfaces (scrolling schedule list, paging strip, date tabs) are backed by `UICollectionView` and `UIPageViewController` for smooth scrolling even with thousands of events.
- **Deep customization via view factories.** Every cell, header, button, marker, and layout metric is produced by a protocol you can implement — no subclassing, no private API, no fighting the framework.
- **Calendar-aware.** Respects the `\.calendar` environment, custom time zones, first-weekday settings, and locale-driven symbols.
- **Drop-in defaults, escape hatches everywhere.** Start with `YoteiScheduleView(...)` and ship in two lines. Need a branded event pill? Implement one factory method. Need a fully custom day cell? Implement another. You are never locked in.
- **Modern Swift.** Swift 6.2, strict concurrency, `@MainActor`-correct factories, `Sendable` domain types.
- **Production ready.** Support for iOS 16+ makes Yotei available not only for modern startups but even for mature projects.

## Requirements

- iOS 16+
- Swift 6.2+
- Xcode 16+

## Installation

### Swift Package Manager

Add Yotei to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/claustrofob/Yotei.git", branch: "main"),
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["Yotei"]
)
```

Or in Xcode: **File → Add Package Dependencies…** and enter `https://github.com/claustrofob/Yotei.git`.

Then import where needed:

```swift
import Yotei
```

## Quick Start

A minimal agenda-style calendar with the built-in strip, weekday titles, and a scrolling schedule list:

```swift
import SwiftUI
import Yotei

struct CalendarScreen: View {
    @State private var focusedDate = Date()
    @State private var data = YoteiEventsInterval()

    var body: some View {
        VStack(spacing: 0) {
            YoteiWeekdayTitlesView()
            YoteiStripContainerView(focusedDate: $focusedDate)
            YoteiScheduleView(
                focusedDate: $focusedDate,
                data: data
            )
        }
        .onChange(of: focusedDate) { _ in
            // Load events for the visible month and assign them to `data.events`
        }
    }
}
```

A standalone date picker with a min/max range:

```swift
import SwiftUI
import Yotei

struct PickerScreen: View {
    @State private var selectedDate = Date()

    var body: some View {
        YoteiDatePicker(
            selectedDate: $selectedDate,
            minDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            maxDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())
        )
        .padding()
    }
}
```

A full day view with an all-day header and a scrollable hour timeline:

```swift
YoteiPagesDayView(focusedDate: $focusedDate) { date in
    VStack(spacing: 0) {
        YoteiAllDayEventsTopView(
            startDate: date,
            numberOfDays: 1,
            data: data
        )
        YoteiDayEventsView(
            startDate: date,
            numberOfDays: 1,
            data: data,
            contentOffset: $contentOffset
        )
    }
}
```

A full month grid with paging between months and multi-day event bars:

```swift
VStack(spacing: 0) {
    YoteiWeekdayTitlesView()
    YoteiPagesMonthView(focusedDate: $focusedDate) { date in
        YoteiPagesMonthPageView(
            selectedDate: $focusedDate,
            data: data,
            dateInMonth: date
        )
    }
}
```

## Typed Event Data

`YoteiEvent` is generic over a `Data` payload so you can carry your own domain model alongside the calendar fields without subclassing, wrapping, or type-erasing:

```swift
public struct YoteiEvent<Data: YoteiEventData>: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let start: Date
    public let end: Date
    public let isAllDay: Bool
    public let data: Data
}

public typealias YoteiEventData = Equatable & Sendable
```

`Data` is whatever you need — a color, a list of attendees, a remote ID, a source enum, a full DTO from your backend. The only requirement is that it is `Equatable` and `Sendable`.

### Attach your domain model

```swift
nonisolated struct EventPayload: Equatable, Sendable {
    let calendarID: String
    let tint: Color
    let attendees: [String]
    let isReadOnly: Bool
}

let event = YoteiEvent(
    id: "evt-42",
    title: "Design review",
    start: start,
    end: end,
    isAllDay: false,
    data: EventPayload(
        calendarID: "work",
        tint: .indigo,
        attendees: ["alex", "sam"],
        isReadOnly: false
    )
)
```

The generic parameter propagates through the whole pipeline so your payload is available at every extension point, fully typed.

### Read your payload inside factories

```swift
struct TintedDayEventsFactory: YoteiDayEventsViewFactoryProtocol {
    func eventView(event: YoteiEvent<EventPayload>) -> some View {
        YoteiDayEventsViewFactory()
            .eventView(event: event)
            .tint(event.data.tint)
            .opacity(event.data.isReadOnly ? 0.6 : 1.0)
    }
}
```

### Don't need extra data?

Use an empty marker struct:

```swift
nonisolated struct EventData: Equatable, Sendable {}
```

You pay nothing for the generic — the payload is a zero-sized field — and you can introduce real data later without rewriting any call sites.

## Colors Customization

Every default view uses standard SwiftUI shape styles — `.tint`, `.background`, `.primary`, `.secondary`, `.tertiary` — so you can re-color the calendar with the standart SwiftUI modifiers:
- `.foregroundStyle(_:_:_:)` - redefine .primary, .secondary and .tertiary styles
- `.backgroundStyle(_:)` - redefine .background style
- `.tint(_:)` - redefine .tint style

You have a few options to set custiom colors in calendar:
- apply the above modifiers globally on calendar component
- aply them on individual default views in [custom view factories](#customization-with-view-factories)
- use your custom views with custom colors in view factories.

### Examples

```swift
VStack(spacing: 0) {
    YoteiWeekdayTitlesView()
    YoteiStripContainerView(focusedDate: $focusedDate)
    YoteiScheduleView(focusedDate: $focusedDate, data: data)
}
.tint(.purple)
```

Because `.tint` is a normal SwiftUI environment value, you can scope it to one component too — tint only the strip, only the schedule, only one page:

```swift
YoteiStripContainerView(focusedDate: $focusedDate)
    .tint(.indigo)

YoteiScheduleView(focusedDate: $focusedDate, data: data)
    .tint(.orange)
```

Inside a view factory you can apply `.tint` on a per-event basis using the typed `event.data` payload — the default event view fills with `.tint`, so changing the tint changes the pill color:

```swift
struct BrandedDayEventsFactory: YoteiDayEventsViewFactoryProtocol {
    func eventView(event: YoteiEvent<EventPayload>) -> some View {
        YoteiDayEventsViewFactory()
            .eventView(event: event)
            .tint(event.data.tint)
    }
}
```

Default cells render text with `.primary` / `.secondary` / `.tertiary` and surfaces with `.background`, so they automatically follow the system's light/dark appearance and any `.preferredColorScheme(_:)` you set. To diverge from the system palette, wrap the default factory output and apply `.foregroundStyle(_:)` or `.background(_:)` on top — there is no need to re-implement the cell.

For anything finer-grained — borders, gradients, conditional colors per state — drop into a [view factory](#customization-with-view-factories) and override only the method you need.

## Fonts Customization

Every default view renders text using a small, shared set of font roles exposed via `YoteiFontStyle`.
The active style lives in the SwiftUI environment under `\.yoteiFontStyle`, so you can override it globally on a calendar component, scope it to an individual view, or apply it inside a view factory.

You have a few options to set custom fonts in calendar:
- inject a custom `YoteiFontStyle` globally on calendar component via the `\.yoteiFontStyle` environment key
- inject it on individual default views in [custom view factories](#customization-with-view-factories)
- use your custom views with custom fonts in view factories.

### Example

Apply a branded font style to the whole calendar:

```swift
VStack(spacing: 0) {
    YoteiWeekdayTitlesView()
    YoteiStripContainerView(focusedDate: $focusedDate)
    YoteiScheduleView(focusedDate: $focusedDate, data: data)
}
.environment(\.yoteiFontStyle, YoteiFontStyle(
    caption: .system(.caption, design: .rounded),
    caption2: .system(.caption2, design: .rounded),
    body: .system(.body, design: .rounded),
    headline: .system(.headline, design: .rounded).weight(.semibold),
    subheadline: .system(.subheadline, design: .rounded)
))
```

Scope styles to a single component:

```swift
YoteiStripContainerView(focusedDate: $focusedDate)
    .environment(\.yoteiFontStyle, YoteiFontStyle(headline: .title3.bold()))
```

Override individual styles:

```swift
YoteiScheduleView(focusedDate: $focusedDate, data: data)
    .environment(\.yoteiFontStyle.subheadline, .custom("Avenir-Heavy", size: 16))
    .environment(\.yoteiFontStyle.caption2, .custom("Avenir-Book", size: 12))
```

## Customization with View Factories

Every event-aware component accepts a **view factory** — a protocol with default implementations. Override only the methods you care about; the rest stay at their defaults.

### Example: custom-colored day-timeline events

```swift
import SwiftUI
import Yotei

struct BrandedDayEventsFactory: YoteiDayEventsViewFactoryProtocol {
    private let palette: [Color] = [.red, .blue, .yellow, .green, .purple]

    func eventView(event: YoteiEvent) -> some View {
        let color = palette[abs(event.id.hashValue) % palette.count]
        return YoteiDayEventsViewFactory()
            .eventView(event: event)
            .tint(color)
    }

    func timeSlotView(date: Date) -> some View {
        MyCustomTimeSlotRow(date: date)
    }
}
```

Use it:

```swift
YoteiDayEventsView(
    startDate: focusedDate,
    numberOfDays: 1,
    data: data,
    contentOffset: $contentOffset,
    viewFactory: BrandedDayEventsFactory()
)
```

### Example: custom strip expand indicator

```swift
struct PurpleStripFactory: YoteiStripViewFactoryProtocol {
    func expandView(isExpanded: Bool) -> some View {
        YoteiStripViewFactory()
            .expandView(isExpanded: isExpanded)
            .foregroundStyle(.purple)
    }
}

YoteiStripContainerView(
    focusedDate: $focusedDate,
    viewFactory: PurpleStripFactory()
)
```

Because factories are plain structs with protocol-provided defaults, you can start by overriding a single method and add more as your design grows. You can also wrap the default factory (`YoteiScheduleViewFactory()`, `YoteiDayEventsViewFactory()`, etc.) and apply SwiftUI modifiers on top of its output instead of re-implementing a view from scratch.

## Handling User Interaction

Implement `YoteiDelegate` and pass it to calendar using `.yoteiDelegate(_:)` modifier:

```swift
final class CalendarCoordinator: YoteiDelegate {
    func calendarDidSelectEvent(with id: YoteiEvent.ID) {
        // Open event detail
    }

    func calendarDidSelectAllDay(date: Date) {
        // Show the all-day list for that day
    }

    func calendarDidSelect(dateInterval: DateInterval, completion: () -> Void) {
        // The user tapped an empty time slot — show a "new event" sheet.
        // Call completion() to clear the placeholder when the sheet is dismissed.
    }

    func calendarDidSelectMonthDay(date: Date) {
        // The user tapped a day cell in the month view — open the day's agenda or switch scope.
    }

    func calendarDidUpdateEvent(
        with id: YoteiEvent.ID,
        oldDateInterval: DateInterval,
        newDateInterval: DateInterval
    ) {
        // The user dragged an event to a new time — persist the new interval.
    }
}
```

## Drag to Reschedule

`YoteiDragEventView` adds **drag-to-reschedule** to a day or week timeline without forcing you to rebuild the timeline itself. Wrap it around an existing `YoteiPagesDayView` / `YoteiPagesWeekView` (with `YoteiDayEventsView` inside) and the new gesture layer is live — long-press an event to "pick it up", drag it to a new time slot, release to commit.

### What it does for you

- **Long-press + pan gesture.** A long press on an event activates drag mode, and the subsequent pan moves a floating proxy view.
- **Auto-scroll near vertical edges.** When the finger gets close to the top or bottom of the visible area, the inner timeline scrolls automatically — proportional to how close you are to the edge — so you can drop an event onto a time that wasn't on screen.
- **Page flip near horizontal edges.** When the finger lingers near the left or right edge, the focused date jumps one page (one day in `YoteiPagesDayView`, one week in `YoteiPagesWeekView`).
- **Time snapping.** The new start time snaps to a configurable minute interval (default `15`).
- **Cross-day moves.** Dropping an event onto a different day column moves it to that day; the duration is preserved.
- **Delegate-based commit.** On release, Yotei calls `calendarDidUpdateEvent(with:oldDateInterval:newDateInterval:)` on your `YoteiDelegate`. Persist the change in your store and the calendar re-renders from the updated `data`.

### Wiring it up

`YoteiDragEventView` needs the same three bindings the underlying timeline uses (`data`, `contentOffset`, `focusedDate`) so it can read event frames, drive auto-scroll, and trigger page flips. Keep the contained `YoteiPagesDayView` / `YoteiPagesWeekView` and `YoteiDayEventsView` exactly as you had them — just wrap them.

Day view with drag-to-reschedule:

```swift
@State private var focusedDate = Date()
@State private var data = YoteiEventsInterval<EventData>()
@State private var contentOffset: CGPoint?

var body: some View {
    VStack(spacing: 0) {
        YoteiWeekdayTitlesView()
        YoteiStripContainerView(focusedDate: $focusedDate)
        YoteiDragEventView(
            data: data,
            contentOffset: $contentOffset,
            focusedDate: $focusedDate
        ) {
            YoteiPagesDayView(focusedDate: $focusedDate) { date in
                VStack(spacing: 0) {
                    YoteiAllDayEventsTopView(
                        startDate: date,
                        numberOfDays: 1,
                        data: data
                    )
                    YoteiDayEventsView(
                        startDate: date,
                        numberOfDays: 1,
                        data: data,
                        contentOffset: $contentOffset
                    )
                }
            }
        }
    }
    .yoteiDelegate(coordinator)
}
```

### Persisting the new time

Implement `calendarDidUpdateEvent` on your `YoteiDelegate` and update the event in your store. Once `data.events` reflects the move, the calendar re-renders automatically:

```swift
final class CalendarCoordinator: YoteiDelegate {
    func calendarDidUpdateEvent(
        with id: YoteiEvent<EventData>.ID,
        oldDateInterval: DateInterval,
        newDateInterval: DateInterval
    ) {
        store.updateEvent(id: id, newStart: newDateInterval.start, newEnd: newDateInterval.end)
    }

    // … other YoteiDelegate methods …
}
```

## Example App

A full example app is bundled in `YoteiAppExample/`. It demonstrates different usage examples and possible customization options.

To run it:

1. Clone the repository: `git clone https://github.com/claustrofob/Yotei.git`
2. Open `YoteiAppExample/YoteiAppExample.xcodeproj` in Xcode 16 or newer.
3. Select an iOS 16+ simulator or device.
4. Build and run (`⌘R`).

The example project depends on the local `Yotei` package at the repo root, so any edits you make to `Sources/` are picked up on the next build.

## Roadmap

- [x] Color customization for every component
- [x] Custom views for events
- [x] Stability improvements
- [x] Font customization
- [x] Month view
- [x] Drag/drop to update event time/duration
- [ ] Accessibility

## License

Copyright © 2026 Mikalai Zmachynski. All rights reserved.

[^1]: Named after the Japanese word 予定 (yotei), meaning "schedule" or "planned event".
