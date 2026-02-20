//
//  GamesViewController.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import UIKit

final class GamesViewController: UIViewController {

    private let viewModel: GamesViewModelProtocol = GamesViewModel()

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView = UIView()

    // Hero section
    private let heroView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let heroGradientLayer = CAGradientLayer()

    private let gameIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Higher or Lower"
        label.font = .systemFont(ofSize: 32, weight: .black)
        label.textColor = .white
        return label
    }()

    private let gameTaglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Guess which anime has the higher rating"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.numberOfLines = 2
        return label
    }()

    private let howToPlayLabel: UILabel = {
        let label = UILabel()
        label.text = "10 questions · Tap the higher rated anime · Track your score"
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 2
        return label
    }()

    // Stats section
    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.secondaryBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let highScoreCard = StatsCardView(icon: "star.fill", title: "Best Score", color: UIColor.theme.accent)
    private let bestStreakCard = StatsCardView(icon: "flame.fill", title: "Best Streak", color: .systemOrange)

    // Play button
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  Play Now", for: .normal)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.theme.primary
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.theme.primary.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.4
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradientLayer.frame = heroView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadStats()
    }

    // MARK: - Setup

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background
        title = "Games"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(heroView)
        contentView.addSubview(statsContainerView)
        contentView.addSubview(playButton)

        statsContainerView.addSubview(highScoreCard)
        statsContainerView.addSubview(bestStreakCard)

        // Hero inner
        heroView.addSubview(gameIconView)
        heroView.addSubview(gameTitleLabel)
        heroView.addSubview(gameTaglineLabel)
        heroView.addSubview(howToPlayLabel)

        // Gradient
        heroGradientLayer.colors = [
            UIColor.theme.primary.cgColor,
            UIColor.theme.secondary.cgColor
        ]
        heroGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        heroGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        heroView.layer.insertSublayer(heroGradientLayer, at: 0)

        // ScrollView
        scrollView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )

        contentView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor
        )
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Hero card (large, prominent)
        heroView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 240
        )

        gameIconView.anchor(
            top: heroView.topAnchor,
            leading: heroView.leadingAnchor,
            paddingTop: 28,
            paddingLeading: 24,
            width: 56,
            height: 56
        )

        gameTitleLabel.anchor(
            top: gameIconView.bottomAnchor,
            leading: heroView.leadingAnchor,
            trailing: heroView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 24,
            paddingTrailing: 24
        )

        gameTaglineLabel.anchor(
            top: gameTitleLabel.bottomAnchor,
            leading: heroView.leadingAnchor,
            trailing: heroView.trailingAnchor,
            paddingTop: 6,
            paddingLeading: 24,
            paddingTrailing: 24
        )

        howToPlayLabel.anchor(
            top: gameTaglineLabel.bottomAnchor,
            leading: heroView.leadingAnchor,
            trailing: heroView.trailingAnchor,
            paddingTop: 10,
            paddingLeading: 24,
            paddingTrailing: 24
        )

        // Stats cards
        statsContainerView.anchor(
            top: heroView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 100
        )

        highScoreCard.anchor(
            top: statsContainerView.topAnchor,
            leading: statsContainerView.leadingAnchor,
            bottom: statsContainerView.bottomAnchor,
            paddingTop: 12,
            paddingLeading: 12,
            paddingBottom: 12
        )
        highScoreCard.widthAnchor.constraint(
            equalTo: statsContainerView.widthAnchor,
            multiplier: 0.5,
            constant: -18
        ).isActive = true

        bestStreakCard.anchor(
            top: statsContainerView.topAnchor,
            bottom: statsContainerView.bottomAnchor,
            trailing: statsContainerView.trailingAnchor,
            paddingTop: 12,
            paddingBottom: 12,
            paddingTrailing: 12
        )
        bestStreakCard.widthAnchor.constraint(
            equalTo: statsContainerView.widthAnchor,
            multiplier: 0.5,
            constant: -18
        ).isActive = true

        // Play button
        playButton.anchor(
            top: statsContainerView.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 24,
            paddingLeading: 20,
            paddingBottom: 32,
            paddingTrailing: 20,
            height: 60
        )
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        let highScore = viewModel.highScore
        let bestStreak = viewModel.bestStreak

        highScoreCard.setValue(highScore > 0 ? "\(highScore)" : "--")
        bestStreakCard.setValue(bestStreak > 0 ? "\(bestStreak)/10" : "--")
    }

    // MARK: - Actions

    @objc private func playButtonTapped() {
        let gamePlayVC = GamesDetailViewController()
        gamePlayVC.modalPresentationStyle = .fullScreen
        present(gamePlayVC, animated: true)
    }
}

// MARK: - StatsCardView

private final class StatsCardView: UIView {

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.theme.textSecondary
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        return label
    }()

    init(icon: String, title: String, color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = UIColor.theme.background
        layer.cornerRadius = 12

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        titleLabel.text = title
        valueLabel.text = "--"

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        iconView.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            paddingTop: 12,
            paddingLeading: 14,
            width: 20,
            height: 20
        )

        titleLabel.anchor(
            top: topAnchor,
            leading: iconView.trailingAnchor,
            trailing: trailingAnchor,
            paddingTop: 14,
            paddingLeading: 6,
            paddingTrailing: 8
        )

        valueLabel.anchor(
            top: iconView.bottomAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: trailingAnchor,
            paddingTop: 4,
            paddingLeading: 14,
            paddingBottom: 12,
            paddingTrailing: 8
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
