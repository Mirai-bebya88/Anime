//
//  AnimeDetailViewController.swift
//  Anime
//
//  Created by elene malakmadze on 11.02.26.
//

import UIKit
import Kingfisher
import SafariServices

final class AnimeDetailViewController: UIViewController {

    private let viewModel: AnimeDetailViewModelProtocol

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView = UIView()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.theme.secondaryBackground
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let imageOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var trailerButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(trailerButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private let infoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        return sv
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.theme.accent
        return label
    }()

    private let episodesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.theme.textSecondary
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.theme.textSecondary
        return label
    }()

    private let watchStatusStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var planButton = createStatusButton(title: "Plan to Watch", status: .plan)

    private let synopsisHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Synopsis"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        return label
    }()

    private let synopsisLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.theme.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(anime: Anime) {
        self.viewModel = AnimeDetailViewModel(anime: anime)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
        configureWithAnime(viewModel.anime)
        loadDetails()
    }

    private func setUpUI() {
        view.backgroundColor = UIColor.theme.background
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)

        contentView.addSubview(coverImageView)
        contentView.addSubview(imageOverlayView)
        imageOverlayView.addSubview(trailerButton)
        imageOverlayView.addSubview(favoriteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(synopsisHeaderLabel)
        contentView.addSubview(synopsisLabel)
        contentView.addSubview(watchStatusStackView)

        infoStackView.addArrangedSubview(ratingLabel)
        infoStackView.addArrangedSubview(episodesLabel)
        infoStackView.addArrangedSubview(yearLabel)

        watchStatusStackView.addArrangedSubview(planButton)

        scrollView.fillSuperview()
        loadingIndicator.center(in: view)

        contentView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor
        )
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        coverImageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            height: 320
        )

        imageOverlayView.anchor(
            top: coverImageView.topAnchor,
            leading: coverImageView.leadingAnchor,
            bottom: coverImageView.bottomAnchor,
            trailing: coverImageView.trailingAnchor
        )

        trailerButton.anchor(
            bottom: imageOverlayView.bottomAnchor,
            trailing: favoriteButton.leadingAnchor,
            paddingBottom: 12,
            paddingTrailing: 16,
            width: 44,
            height: 44
        )

        favoriteButton.anchor(
            bottom: imageOverlayView.bottomAnchor,
            trailing: imageOverlayView.trailingAnchor,
            paddingBottom: 12,
            paddingTrailing: 16,
            width: 44,
            height: 44
        )

        titleLabel.anchor(
            top: coverImageView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        infoStackView.anchor(
            top: titleLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            paddingTop: 8,
            paddingLeading: 16
        )

        synopsisHeaderLabel.anchor(
            top: infoStackView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        synopsisLabel.anchor(
            top: synopsisHeaderLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        watchStatusStackView.anchor(
            top: synopsisLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 24,
            paddingLeading: 16,
            paddingBottom: 32,
            paddingTrailing: 16,
            height: 44
        )
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
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
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }

    private func loadDetails() {
        Task {
            await viewModel.loadDetails()
        }
    }

    private func configureWithAnime(_ anime: Anime) {
        titleLabel.text = anime.displayTitle

        if let score = anime.score, score > 0 {
            ratingLabel.text = "★ \(String(format: "%.1f", score))"
        } else {
            ratingLabel.text = "★ N/A"
        }

        if let episodes = anime.episodes, episodes > 0 {
            episodesLabel.text = "\(episodes) eps"
        } else {
            episodesLabel.text = "? eps"
        }

        if let year = anime.year {
            yearLabel.text = "\(year)"
        } else {
            yearLabel.isHidden = true
        }

        synopsisLabel.text = anime.synopsis ?? "No synopsis available."

        if let imageURL = anime.largeImageURL, let url = URL(string: imageURL) {
            coverImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }

        updateStatusButtons()
        updateFavoriteButton()
    }

    private func updateUI() {
        configureWithAnime(viewModel.currentAnime)
        updateStatusButtons()
        updateFavoriteButton()
    }

    private func updateStatusButtons() {
        let currentStatus = viewModel.currentWatchStatus

        [planButton].forEach { button in
            button.backgroundColor = UIColor.theme.secondaryBackground
            button.setTitleColor(UIColor.theme.textPrimary, for: .normal)
        }

        let selectedButton: UIButton?
        switch currentStatus {
        case .plan: selectedButton = planButton
        case .watching: selectedButton = nil
        case .none: selectedButton = nil
        }

        selectedButton?.backgroundColor = UIColor.theme.primary
        selectedButton?.setTitleColor(.white, for: .normal)
    }

    private func updateFavoriteButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        favoriteButton.tintColor = viewModel.isFavorite ? UIColor.theme.error : .white
    }

    @objc private func trailerButtonTapped() {
        let trailer = viewModel.currentAnime.trailer
        var videoId: String? = trailer?.youtubeId

        if let id = videoId, id != "" {
            // videoId is already valid
        } else if let embedUrl = trailer?.embedUrl {
            videoId = extractYouTubeId(from: embedUrl)
        } else if let url = trailer?.url {
            videoId = extractYouTubeId(from: url)
        }

        if let id = videoId, id != "",
           let url = URL(string: "https://www.youtube.com/watch?v=\(id)") {
            viewModel.saveToList(status: .watching)
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        } else {
            showError("No trailer available for this anime")
        }
    }

    private func extractYouTubeId(from url: String) -> String? {
        if let range = url.range(of: "/embed/") {
            let afterEmbed = url[range.upperBound...]
            if let endRange = afterEmbed.range(of: "?") {
                return String(afterEmbed[..<endRange.lowerBound])
            }
            return String(afterEmbed)
        }
        if let range = url.range(of: "v=") {
            let afterV = url[range.upperBound...]
            if let endRange = afterV.range(of: "&") {
                return String(afterV[..<endRange.lowerBound])
            }
            return String(afterV)
        }
        return nil
    }

    @objc private func favoriteButtonTapped() {
        if viewModel.isFavorite {
            viewModel.removeFromFavorites()
        } else {
            viewModel.addToFavorites()
        }
        updateFavoriteButton()
    }

    @objc private func statusButtonTapped(_ sender: UIButton) {
        guard let status = sender.layer.value(forKey: "status") as? String,
              let watchStatus = WatchStatus(rawValue: status) else { return }

        if viewModel.currentWatchStatus == watchStatus {
            showRemoveConfirmation()
        } else {
            viewModel.saveToList(status: watchStatus)
        }
        updateFavoriteButton()
    }

    private func showRemoveConfirmation() {
        let alert = UIAlertController(
            title: "Remove from List",
            message: "Are you sure you want to remove this anime from your list?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.viewModel.removeFromList()
        })
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func createStatusButton(title: String, status: WatchStatus) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = UIColor.theme.secondaryBackground
        button.setTitleColor(UIColor.theme.textPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.setValue(status.rawValue, forKey: "status")
        button.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        return button
    }
}
