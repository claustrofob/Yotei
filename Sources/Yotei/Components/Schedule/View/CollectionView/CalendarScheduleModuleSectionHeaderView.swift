import UIKit

final class CalendarScheduleModuleSectionHeaderView: UICollectionReusableView {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    private let titleLabel = Label(
        fontStyle: .subhead1,
        textColorStyle: .base80,
        backgroundColorStyle: .clear
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented for HomeListModuleSectionHeaderView")
    }

    private func setupLayout() {
        titleLabel.numberOfLines = 1
        backgroundColorStyle = .base

        pinSubview(titleLabel, with: .init(top: 0, left: 16, bottom: 0, right: 16))
    }

    func apply(date: Date) {
        titleLabel.text = date.formatted(dateFormatStyle).capitalizedFirstLetter
        titleLabel.textColorStyle = date.isInSameDay(as: .now) ? .base110 : .base80
    }
}
