//
//  StatBarView.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import UIKit

final class StatBarView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.theme.textPrimary
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .right
        return label
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = UIColor.theme.secondaryBackground
        pv.layer.cornerRadius = 2
        pv.clipsToBounds = true
        return pv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(progressView)

        titleLabel.anchor(
            top: topAnchor,
            leading: leadingAnchor
        )

        countLabel.anchor(
            top: topAnchor,
            trailing: trailingAnchor
        )

        progressView.anchor(
            top: titleLabel.bottomAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            paddingTop: 4,
            height: 6
        )
    }

    func configure(title: String, count: Int, progress: Float, color: UIColor) {
        titleLabel.text = title
        countLabel.text = "\(count)"
        progressView.progress = progress
        progressView.progressTintColor = color
    }
}
