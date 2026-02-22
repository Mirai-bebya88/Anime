//
//  AnimeCardView.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import UIKit
import Kingfisher

final class AnimeCardView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let gradientView: UIView = {
        let view = UIView()
        return view
    }()

    private let gradientLayer = CAGradientLayer()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .black)
        label.textColor = .white
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    private let winnerBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.accent
        view.layer.cornerRadius = 12
        view.isHidden = true

        let label = UILabel()
        label.text = "★ Higher"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    private func setupUI() {
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.15

        addSubview(imageView)
        addSubview(gradientView)
        addSubview(winnerBadge)
        addSubview(titleLabel)
        addSubview(scoreLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        winnerBadge.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),

            winnerBadge.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            winnerBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -8),

            scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            scoreLabel.widthAnchor.constraint(equalToConstant: 72)
        ])

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }

    func configure(with anime: Anime, showScore: Bool, isWinner: Bool) {
        titleLabel.text = anime.displayTitle
        winnerBadge.isHidden = !isWinner

        if showScore, let score = anime.score {
            scoreLabel.text = String(format: "%.2f", score)
            scoreLabel.isHidden = false
        } else {
            scoreLabel.isHidden = true
        }

        if let imageURL = anime.largeImageURL ?? anime.imageURL, let url = URL(string: imageURL) {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        }
    }
}
