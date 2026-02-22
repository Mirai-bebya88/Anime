//
//  GamesDetailViewController.swift
//  Anime
//
//  Created by elene malakmadze on 20.02.26.
//

import UIKit
import Kingfisher

final class GamesDetailViewController: UIViewController {

    private let viewModel: GamesDetailViewModelProtocol = GamesDetailViewModel()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.theme.textSecondary
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor.theme.textSecondary
        return label
    }()

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = "Which anime has a higher rating?"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var topCardView = createAnimeCard()
    private lazy var bottomCardView = createAnimeCard()

    private let vsLabel: UILabel = {
        let label = UILabel()
        label.text = "VS"
        label.font = .systemFont(ofSize: 22, weight: .black)
        label.textColor = UIColor.theme.secondary
        label.textAlignment = .center
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let statsBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.secondaryBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let streakLabel: UILabel = {
        let label = UILabel()
        label.text = "Streak: 0/10"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.theme.accent
        label.textAlignment = .center
        return label
    }()

    private let gameOverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.background.withAlphaComponent(0.96)
        view.isHidden = true
        return view
    }()

    private let gameOverLabel: UILabel = {
        let label = UILabel()
        label.text = "Game Over!"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let finalScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 52, weight: .black)
        label.textColor = UIColor.theme.primary
        label.textAlignment = .center
        return label
    }()

    private let finalSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.theme.primary
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        return button
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Exit", for: .normal)
        button.setTitleColor(UIColor.theme.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.theme.secondaryBackground
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        startGame()
    }

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background

        view.addSubview(closeButton)
        view.addSubview(progressLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(topCardView)
        view.addSubview(vsLabel)
        view.addSubview(bottomCardView)
        view.addSubview(statsBar)
        view.addSubview(loadingIndicator)
        view.addSubview(gameOverView)

        statsBar.addSubview(scoreLabel)
        statsBar.addSubview(streakLabel)

        gameOverView.addSubview(gameOverLabel)
        gameOverView.addSubview(finalScoreLabel)
        gameOverView.addSubview(finalSubtitleLabel)
        gameOverView.addSubview(playAgainButton)
        gameOverView.addSubview(exitButton)

        closeButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 12,
            paddingTrailing: 16,
            width: 32,
            height: 32
        )

        progressLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            paddingTop: 16,
            paddingLeading: 20
        )

        feedbackLabel.anchor(
            top: progressLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        statsBar.anchor(
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            height: 80
        )

        scoreLabel.anchor(
            top: statsBar.topAnchor,
            leading: statsBar.leadingAnchor,
            paddingTop: 18,
            paddingLeading: 24
        )

        streakLabel.anchor(
            top: statsBar.topAnchor,
            trailing: statsBar.trailingAnchor,
            paddingTop: 18,
            paddingTrailing: 24
        )

        let cardAreaTop = feedbackLabel.bottomAnchor
        let cardAreaBottom = statsBar.topAnchor

        topCardView.anchor(
            top: cardAreaTop,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        vsLabel.anchor(
            top: topCardView.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 4
        )
        vsLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

        bottomCardView.anchor(
            top: vsLabel.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: cardAreaBottom,
            trailing: view.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        topCardView.heightAnchor.constraint(equalTo: bottomCardView.heightAnchor).isActive = true

        loadingIndicator.center(in: view)

        gameOverView.fillSuperview()

        gameOverLabel.anchor(
            leading: gameOverView.leadingAnchor,
            trailing: gameOverView.trailingAnchor,
            paddingLeading: 20,
            paddingTrailing: 20
        )
        gameOverLabel.centerY(in: gameOverView)
        gameOverLabel.centerYAnchor.constraint(equalTo: gameOverView.centerYAnchor, constant: -120).isActive = true

        finalScoreLabel.anchor(
            top: gameOverLabel.bottomAnchor,
            leading: gameOverView.leadingAnchor,
            trailing: gameOverView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        finalSubtitleLabel.anchor(
            top: finalScoreLabel.bottomAnchor,
            leading: gameOverView.leadingAnchor,
            trailing: gameOverView.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        playAgainButton.anchor(
            top: finalSubtitleLabel.bottomAnchor,
            leading: gameOverView.leadingAnchor,
            trailing: gameOverView.trailingAnchor,
            paddingTop: 48,
            paddingLeading: 40,
            paddingTrailing: 40,
            height: 52
        )

        exitButton.anchor(
            top: playAgainButton.bottomAnchor,
            leading: gameOverView.leadingAnchor,
            trailing: gameOverView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 40,
            paddingTrailing: 40,
            height: 52
        )
    }

    private func createAnimeCard() -> AnimeCardView {
        let cardView = AnimeCardView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
        return cardView
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }

        viewModel.onCorrectAnswer = { [weak self] in
            DispatchQueue.main.async {
                self?.showAnswerFeedback(correct: true)
            }
        }

        viewModel.onWrongAnswer = { [weak self] in
            DispatchQueue.main.async {
                self?.showAnswerFeedback(correct: false)
            }
        }

        viewModel.onGameOver = { [weak self] in
            DispatchQueue.main.async {
                self?.showGameOver()
            }
        }

        viewModel.showError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }

        viewModel.showLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.topCardView.isHidden = true
                    self?.bottomCardView.isHidden = true
                    self?.vsLabel.isHidden = true
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.topCardView.isHidden = false
                    self?.bottomCardView.isHidden = false
                    self?.vsLabel.isHidden = false
                }
            }
        }
    }

    private func startGame() {
        Task {
            await viewModel.startNewGame()
        }
    }

    private func updateUI() {
        let questionNumber = min(viewModel.questionsAnswered + 1, viewModel.totalQuestions)
        progressLabel.text = "Question \(questionNumber)/\(viewModel.totalQuestions)"

        scoreLabel.text = "Score: \(viewModel.currentScore)"
        streakLabel.text = "Streak: \(viewModel.currentScore)/\(viewModel.totalQuestions)"

        feedbackLabel.text = "Which anime has a higher rating?"
        feedbackLabel.textColor = UIColor.theme.textPrimary

        if let top = viewModel.topAnime {
            topCardView.configure(with: top, showScore: false, isWinner: false)
        }

        if let bottom = viewModel.bottomAnime {
            bottomCardView.configure(with: bottom, showScore: false, isWinner: false)
        }

        topCardView.isUserInteractionEnabled = true
        bottomCardView.isUserInteractionEnabled = true
    }

    private func showAnswerFeedback(correct: Bool) {
        topCardView.isUserInteractionEnabled = false
        bottomCardView.isUserInteractionEnabled = false

        guard let top = viewModel.topAnime, let bottom = viewModel.bottomAnime else { return }
        let topScore = top.score ?? 0
        let bottomScore = bottom.score ?? 0
        let topIsWinner = topScore >= bottomScore

        topCardView.configure(with: top, showScore: true, isWinner: topIsWinner)
        bottomCardView.configure(with: bottom, showScore: true, isWinner: !topIsWinner)

        if bottomScore > topScore {
            UIView.animate(withDuration: 0.25, delay: 0.3) {
                self.topCardView.alpha = 0
                self.bottomCardView.alpha = 0
            } completion: { _ in
                self.topCardView.configure(with: bottom, showScore: true, isWinner: true)
                self.bottomCardView.configure(with: top, showScore: true, isWinner: false)
                UIView.animate(withDuration: 0.25) {
                    self.topCardView.alpha = 1
                    self.bottomCardView.alpha = 1
                }
            }
        }

        if correct {
            feedbackLabel.textColor = UIColor.theme.success
            feedbackLabel.text = "Correct!"
        } else {
            feedbackLabel.textColor = UIColor.theme.error
            feedbackLabel.text = "Wrong!"
        }

        streakLabel.text = "Streak: \(viewModel.currentScore)/\(viewModel.totalQuestions)"
        scoreLabel.text = "Score: \(viewModel.currentScore)"
    }

    private func showGameOver() {
        let total = viewModel.totalQuestions
        let score = viewModel.currentScore
        finalScoreLabel.text = "\(score)/\(total)"
        finalSubtitleLabel.text = score == total ? "Perfect score! Amazing!" :
            score >= total * 3 / 4 ? "Great job!" :
            score >= total / 2 ? "Not bad!" : "Keep practicing!"

        gameOverView.isHidden = false
        gameOverView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.gameOverView.alpha = 1
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view as? AnimeCardView else { return }
        let selection: GamesDetailViewModel.Selection = cardView == topCardView ? .top : .bottom
        viewModel.selectAnime(selection)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func playAgainTapped() {
        gameOverView.isHidden = true
        feedbackLabel.textColor = UIColor.theme.textPrimary
        feedbackLabel.text = "Which anime has a higher rating?"
        startGame()
    }
}
