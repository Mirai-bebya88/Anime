//
//  AnimeCollectionViewCell.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit
import Kingfisher

final class AnimeCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "AnimeCollectionViewCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor.theme.secondaryBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.theme.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let ratingBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.accent.withAlphaComponent(0.9)
        view.layer.cornerRadius = 4
        return view
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.addSubview(ratingBadge)
        ratingBadge.addSubview(ratingLabel)

        imageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            height: contentView.frame.width * 1.4
        )

        titleLabel.anchor(
            top: imageView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 6
        )

        ratingBadge.anchor(
            top: imageView.topAnchor,
            trailing: imageView.trailingAnchor,
            paddingTop: 6,
            paddingTrailing: 6
        )

        ratingLabel.anchor(
            top: ratingBadge.topAnchor,
            leading: ratingBadge.leadingAnchor,
            bottom: ratingBadge.bottomAnchor,
            trailing: ratingBadge.trailingAnchor,
            paddingTop: 2,
            paddingLeading: 6,
            paddingBottom: 2,
            paddingTrailing: 6
        )
    }

    func configure(with anime: Anime) {
        titleLabel.text = anime.displayTitle

        if let score = anime.score, score > 0 {
            ratingLabel.text = String(format: "%.1f", score)
            ratingBadge.isHidden = false
        } else {
            ratingBadge.isHidden = true
        }

        if let imageURL = anime.imageURL, let url = URL(string: imageURL) {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
    }
}
