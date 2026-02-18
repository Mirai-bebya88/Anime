//
//  DaySelector.swift
//  Anime
//
//  Created by elene malakmadze on 13.02.26.
//

import UIKit

protocol DaySelectorDelegate: AnyObject {
    func daySelector(_ selector: DaySelector, didSelectDay day: String)
}

final class DaySelector: UIView {

    weak var delegate: DaySelectorDelegate?

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private var buttons: [UIButton] = []
    private var selectedIndex = 0

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()

    var selectedDay: String {
        days[selectedIndex]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        selectCurrentDay()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.fillSuperview()

        for (index, day) in days.enumerated() {
            let button = createDayButton(title: day, index: index)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    private func createDayButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.tag = index
        button.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
        updateButtonAppearance(button, isSelected: false)
        return button
    }

    private func selectCurrentDay() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let adjustedIndex = (weekday + 5) % 7
        selectDay(at: adjustedIndex)
    }

    func selectDay(at index: Int) {
        guard index >= 0 && index < days.count else { return }

        updateButtonAppearance(buttons[selectedIndex], isSelected: false)
        selectedIndex = index
        updateButtonAppearance(buttons[selectedIndex], isSelected: true)
    }

    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor.theme.primary
            button.layer.borderColor = UIColor.theme.primary.cgColor
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.layer.borderColor = UIColor.theme.textSecondary.cgColor
            button.setTitleColor(UIColor.theme.textPrimary, for: .normal)
        }
    }

    @objc private func dayButtonTapped(_ sender: UIButton) {
        selectDay(at: sender.tag)
        delegate?.daySelector(self, didSelectDay: days[sender.tag])
    }
}
