//
//  GenreFilterCell.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit

final class GenreFilterCell: UICollectionViewCell {
    static let reuseIdentifier = "GenreFilterCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1

        contentView.addSubview(titleLabel)
        titleLabel.fillSuperview(padding: UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14))

        updateAppearance()
    }

    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = UIColor.theme.primary
            contentView.layer.borderColor = UIColor.theme.primary.cgColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderColor = UIColor.theme.textSecondary.cgColor
            titleLabel.textColor = UIColor.theme.textPrimary
        }
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}
