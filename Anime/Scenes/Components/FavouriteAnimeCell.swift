//
//  FavouriteAnimeCell.swift
//  Anime
//
//  Created by elene malakmadze on 17.02.26.
//

import UIKit
import Kingfisher

final class FavouriteAnimeCell: UITableViewCell {
    static let reuseIdentifier = "FavouriteAnimeCell"

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

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
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
        contentView.addSubview(statusBadge)

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

        statusBadge.anchor(
            top: titleLabel.bottomAnchor,
            leading: animeImageView.trailingAnchor,
            paddingTop: 6,
            paddingLeading: 12
        )
        statusBadge.setContentHuggingPriority(.required, for: .horizontal)
    }

    func configure(with anime: SavedAnime, statusColor: UIColor) {
        titleLabel.text = anime.title

        let status = WatchStatus(rawValue: anime.watchStatus ?? "")?.displayName ?? anime.watchStatus
        statusBadge.text = "  \(status ?? "")  "
        statusBadge.backgroundColor = statusColor

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
    }
}
