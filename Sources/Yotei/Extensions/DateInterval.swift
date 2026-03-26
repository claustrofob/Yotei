import Foundation

public extension DateInterval {
    var durationInDays: Int {
        Calendar.current.dateComponents(
            [.day],
            from: start,
            to: end
        ).day!
    }
}
