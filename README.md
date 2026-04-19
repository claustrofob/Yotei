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

<img width="160" src="https://github.com/user-attachments/assets/48167445-6f75-4d98-9e4d-b38a3f97b579" />
<img width="160" src="https://github.com/user-attachments/assets/223a3769-d552-4af7-b322-ac48ec13c13a" />
<img width="160" src="https://github.com/user-attachments/assets/47688997-a821-47c6-9a9d-aa140bf69ef6" />
<img width="160" src="https://github.com/user-attachments/assets/761c6ac9-75be-4ee5-8b97-265e8bc38dce" />
<img width="160" src="https://github.com/user-attachments/assets/54ca8ad5-ed46-40dd-a76b-fcdda15b7a74" />
<img width="160" src="https://github.com/user-attachments/assets/92e413a8-1923-49e0-9c62-e0907f37fc3c" />

## Table of Contents

- [Features](#features)
- [Why Yotei](#why-yotei)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Available Components](#available-components)
- [Typed Event Data](#typed-event-data)
- [Customization with View Factories](#customization-with-view-factories)
- [Handling User Interaction](#handling-user-interaction)
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

## Why Yotei

Most open-source iOS calendar libraries fall into one of two camps:

- **"Monolithic" components** — one giant view that owns layout, data, theming, and gestures. Great for demos, painful once the design system pushes back.
- **"Bring your own everything"** — low-level primitives that still require you to write the scrolling list, the page controller, and the event layout from scratch.

If you want a date picker today and a full-screen planner tomorrow without switching libraries, Yotei is built for that path.

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
                data: $data,
                delegate: nil
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
            data: $data,
            delegate: nil
        )
        YoteiDayEventsView(
            dayDate: date,
            numberOfDays: 1,
            data: $data,
            contentOffset: $contentOffset,
            delegate: nil
        )
    }
}
```

All three examples use only default configuration — no factories, no subclasses.

## Available Components

Every view below is a public SwiftUI `View` that lives under `import Yotei`.

### Pickers

| Component | Purpose |
|---|---|
| `YoteiDatePicker` | Full month calendar date picker with month/year selector, paging between months, and optional `minDate` / `maxDate`. |
| `YoteiDatePickerMonth` | A single month grid — useful when you want to embed one month into a custom layout. |
| `YoteiMonthYearPicker` | Wheel-style month/year selector used by `YoteiDatePicker` when expanded. |
| `YoteiTimePicker` | Wheel-style time picker (24-hour) with configurable minute interval. |

### Strip / date bars

| Component | Purpose |
|---|---|
| `YoteiStripContainerView` | Collapsible week ↔ month strip with drag-to-expand, paging, and a tap-to-collapse expand button. |
| `YoteiStripWeekView` / `YoteiStripMonthView` | Individual week and month strips exposed for custom containers. |
| `YoteiWeekdayTitlesView` | Localized short weekday titles ("M T W T F S S"), aware of first weekday and locale. |
| `YoteiWeekdaysView` | Row of date cells for a given week start — handy when assembling custom headers. |

### Pagers

| Component | Purpose |
|---|---|
| `YoteiPagesDayView` | Infinite horizontal pager, one page per day. Bound to a focused `Date`. |
| `YoteiPagesWeekView` | Same as above but one page per week, always aligned to the calendar's first weekday. |

### Events

| Component | Purpose |
|---|---|
| `YoteiScheduleView` | Scrolling agenda list grouped by day. UIKit-backed for smooth scroll over large ranges. |
| `YoteiDayEventsView` | Hour-by-hour day timeline with overlap layout, current-time marker, and tap-to-create gesture. Supports multi-day layouts (`numberOfDays: 7` for a week view). |
| `YoteiAllDayEventsTopView` | Multi-column grid for all-day and multi-day events, with a "+N more" indicator. |

### Domain & delegates

| Type | Purpose |
|---|---|
| `YoteiEvent<Data>` | Immutable event model: `id`, `title`, `start`, `end`, `isAllDay`, and a generic `data` payload. Timezone-safe display helpers included. |
| `YoteiEventsInterval` | The data envelope every events view reads from: visible interval, month interval, loading interval, and the `[Date: [YoteiEvent]]` bucket. |
| `YoteiDelegate` | Single delegate protocol for event taps, all-day slot taps, and time-slot selection (tap-to-create). |
| `YoteiDaysSequence` | A lazy, random-access `Collection` of `Date`s — useful when you iterate your own days. |

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

No casting, no `userInfo: [String: Any]`, no lookups into a sidecar dictionary keyed by `event.id`.

### Don't need extra data?

Use an empty marker struct:

```swift
nonisolated struct EventData: Equatable, Sendable {}
```

You pay nothing for the generic — the payload is a zero-sized field — and you can introduce real data later without rewriting any call sites.

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
    dayDate: focusedDate,
    numberOfDays: 1,
    data: $data,
    contentOffset: $contentOffset,
    delegate: nil,
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

Implement `YoteiDelegate` and pass it to any events view:

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
- [ ] Font customization
- [ ] Accessibility

## License

Copyright © 2026 Mikalai Zmachynski. All rights reserved.

[^1]: Named after the Japanese word 予定 (yotei), meaning "schedule" or "planned event".
