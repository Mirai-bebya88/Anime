//
//  AnimeTableViewCell.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit
import Kingfisher

final class AnimeTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AnimeTableViewCell"

    private let animeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor.theme.secondaryBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.theme.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.theme.textSecondary
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.theme.accent
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(animeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(ratingLabel)

        animeImageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            paddingTop: 8,
            paddingLeading: 16,
            paddingBottom: 8,
            width: 70,
            height: 100
        )

        titleLabel.anchor(
            top: animeImageView.topAnchor,
            leading: animeImageView.trailingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 12,
            paddingTrailing: 16
        )

        subtitleLabel.anchor(
            top: titleLabel.bottomAnchor,
            leading: animeImageView.trailingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 12,
            paddingTrailing: 16
        )

        ratingLabel.anchor(
            top: subtitleLabel.bottomAnchor,
            leading: animeImageView.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 12
        )
    }

    func configure(with anime: Anime) {
        titleLabel.text = anime.displayTitle

        var subtitleParts: [String] = []
        if let type = anime.type {
            subtitleParts.append(type)
        }
        if let episodes = anime.episodes, episodes > 0 {
            subtitleParts.append("\(episodes) eps")
        }
        subtitleLabel.text = subtitleParts.joined(separator: " • ")

        if let score = anime.score, score > 0 {
            ratingLabel.text = "★ \(String(format: "%.1f", score))"
        } else {
            ratingLabel.text = ""
        }

        if let imageURL = anime.imageURL, let url = URL(string: imageURL) {
            animeImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            animeImageView.image = UIImage(systemName: "photo")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        animeImageView.kf.cancelDownloadTask()
        animeImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        ratingLabel.text = nil
    }
}
