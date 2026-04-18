//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import Foundation
import Yotei

actor EventsLocalRepository {
    private let eventTitles: [String] = [
        "Q1 All-Hands: Road Ahead",
        "Hackathon: 48 Hours to Ship",
        "Tech Talks: Scaling Beyond 10M Users",
        "New Hire Onboarding Bootcamp",
        "Architecture Review: Payments Service Migration",
        "Women in Engineering Meetup",
        "Incident Postmortem: March 12 Outage",
        "Lunch & Learn: Intro to Kubernetes",
        "Engineering Leadership Offsite",
        "Product Demo Day",
        "Security Awareness Training",
        "Annual Company Retreat",
        "Open Source Friday: Contributing Back",
        "DevOps Guild Sync",
        "Career Growth Workshop: IC to Staff Track",
        "Fireside Chat with CTO",
        "Code Review Best Practices",
        "Intern Showcase & Presentations",
        "Platform Team Roadmap Planning",
        "AI/ML Brown Bag Session",
        "Wellness Week Kickoff",
        "Customer Zero Day: Dogfooding Sprint",
        "Cross-Team Retro: Q2 Release",
        "Data Privacy Compliance Workshop",
        "Holiday Party & Awards Ceremony",
        "Founder's Day Anniversary Celebration",
        "Mobile Guild: SwiftUI vs Compose Deep Dive",
        "Accessibility Audit Workshop",
        "Engineering Book Club: Designing Data-Intensive Applications",
        "Failure Friday: Chaos Engineering Demo",
    ]

    private var events: [Date: [YoteiEvent<EventData>]] = [:]
    private var utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    private func generateEvents(for date: Date, calendar: Calendar) -> [Date: [YoteiEvent<EventData>]] {
        let numberOfEvents = Int.random(in: 0 ..< 6)
        var result = [Date: [YoteiEvent<EventData>]]()
        result[date] = []
        for _ in 0 ..< numberOfEvents {
            let startTime = Int.random(in: 32 ..< 72) * 15
            let isLongEvent = Int.random(in: 0 ..< 4) == 0
            let duration = isLongEvent ? Int.random(in: 12 ..< 48) * 30 : Int.random(in: 1 ..< 6) * 30

            var startDate = calendar.date(byAdding: .minute, value: startTime, to: date)!
            var endDate = calendar.date(byAdding: .minute, value: duration, to: startDate)!

            let isAllDay = Int.random(in: 0 ..< 4) == 0
            if isAllDay {
                startDate = utcCalendar.startOfDay(for: startDate)
                endDate = utcCalendar.startOfDay(
                    for: utcCalendar.date(byAdding: .day, value: 1, to: endDate)!
                )
            }

            let event = YoteiEvent(
                id: UUID().uuidString,
                title: eventTitles[Int.random(in: 0 ..< eventTitles.count)],
                start: startDate,
                end: endDate,
                isAllDay: isAllDay,
                data: EventData()
            )
            let eventDateInterval = event.displayableDateInterval()
            for date in YoteiDaysSequence(interval: eventDateInterval, calendar: calendar) {
                result[date, default: []].append(event)
            }
        }

        return result
    }
}

extension EventsLocalRepository: EventsLocalRepositoryProtocol {
    func events(in dateInterval: DateInterval, calendar: Calendar) -> [Date: [YoteiEvent<EventData>]] {
        var result = [Date: [YoteiEvent<EventData>]]()
        for date in YoteiDaysSequence(interval: dateInterval, calendar: calendar) {
            if events[date] == nil {
                events = events.merging(generateEvents(for: date, calendar: calendar)) { $0 + $1 }
            }
            result[date] = events[date]
        }

        return result
    }

    func resetCache() {
        events = [:]
    }
}
