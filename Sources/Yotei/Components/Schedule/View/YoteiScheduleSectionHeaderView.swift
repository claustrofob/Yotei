//
//  Created by Mikalai Zmachynski.
//  Copyright © 2026 Mikalai Zmachynski. All rights reserved.
//

import UIKit

final class YoteiScheduleSectionHeaderView: UICollectionReusableView {
    private let dateFormatStyle = Date.FormatStyle()
        .month(.wide)
        .day()
        .weekday(.wide)

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented for CalendarScheduleSectionHeaderView")
    }

    private func setupLayout() {
        titleLabel.numberOfLines = 1
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }

    func apply(date: Date) {
        titleLabel.text = date.formatted(dateFormatStyle).capitalizedFirstLetter
        titleLabel.textColor = date.isInSameDay(as: .now) ? UIColor.black : UIColor.black.withAlphaComponent(0.8)
    }
}
