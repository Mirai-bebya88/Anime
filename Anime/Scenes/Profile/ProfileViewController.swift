//
//  ProfileViewController.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let viewModel = ProfileViewModel()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView = UIView()

    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.backgroundColor = UIColor.theme.secondaryBackground
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor.theme.primary
        iv.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        iv.addGestureRecognizer(tapGesture)
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 16
        return sv
    }()

    private let watchStatusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.theme.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let watchStatusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch Status"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        return label
    }()

    private let watchingStatView = StatBarView()
    private let completedStatView = StatBarView()
    private let planStatView = StatBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfile()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.theme.background
        title = "Profile"

        let logoutButton = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = UIColor.theme.error
        navigationItem.rightBarButtonItem = logoutButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(memberSinceLabel)
        contentView.addSubview(statsContainerView)
        contentView.addSubview(watchStatusContainerView)

        statsContainerView.addSubview(statsStackView)
        watchStatusContainerView.addSubview(watchStatusTitleLabel)
        watchStatusContainerView.addSubview(watchingStatView)
        watchStatusContainerView.addSubview(completedStatView)
        watchStatusContainerView.addSubview(planStatView)

        let totalAnimeStatView = createStatView(title: "Total Anime", value: "0")
        let avgScoreStatView = createStatView(title: "Avg Score", value: "-")
        let highestScoreStatView = createStatView(title: "Highest Score", value: "0")

        statsStackView.addArrangedSubview(totalAnimeStatView)
        statsStackView.addArrangedSubview(avgScoreStatView)
        statsStackView.addArrangedSubview(highestScoreStatView)

        scrollView.fillSuperview()

        contentView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor
        )
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        profileImageView.anchor(
            top: contentView.topAnchor,
            paddingTop: 32,
            width: 100,
            height: 100
        )
        profileImageView.centerX(in: contentView)

        nameLabel.anchor(
            top: profileImageView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        memberSinceLabel.anchor(
            top: nameLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        statsContainerView.anchor(
            top: memberSinceLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 24,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        statsStackView.anchor(
            top: statsContainerView.topAnchor,
            leading: statsContainerView.leadingAnchor,
            bottom: statsContainerView.bottomAnchor,
            trailing: statsContainerView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingBottom: 16,
            paddingTrailing: 16
        )

        watchStatusContainerView.anchor(
            top: statsContainerView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        watchStatusTitleLabel.anchor(
            top: watchStatusContainerView.topAnchor,
            leading: watchStatusContainerView.leadingAnchor,
            trailing: watchStatusContainerView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        watchingStatView.anchor(
            top: watchStatusTitleLabel.bottomAnchor,
            leading: watchStatusContainerView.leadingAnchor,
            trailing: watchStatusContainerView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16,
            height: 24
        )

        completedStatView.anchor(
            top: watchingStatView.bottomAnchor,
            leading: watchStatusContainerView.leadingAnchor,
            trailing: watchStatusContainerView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 16,
            paddingTrailing: 16,
            height: 24
        )

        planStatView.anchor(
            top: completedStatView.bottomAnchor,
            leading: watchStatusContainerView.leadingAnchor,
            bottom: watchStatusContainerView.bottomAnchor,
            trailing: watchStatusContainerView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 16,
            paddingBottom: 16,
            paddingTrailing: 16,
            height: 24
        )

        watchStatusContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32).isActive = true
    }

    private func createStatView(title: String, value: String) -> UIView {
        let containerView = UIView()

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = UIColor.theme.primary
        valueLabel.textAlignment = .center
        valueLabel.tag = 100

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.theme.textSecondary
        titleLabel.textAlignment = .center

        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)

        valueLabel.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            trailing: containerView.trailingAnchor
        )

        titleLabel.anchor(
            top: valueLabel.bottomAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            paddingTop: 4
        )

        return containerView
    }

    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        nameLabel.text = viewModel.fullName
        memberSinceLabel.text = "Member since \(viewModel.memberSinceString)"

        if let imageData = viewModel.user?.profileImage,
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        updateStatValue(at: 0, value: "\(viewModel.totalAnime)")
        updateStatValue(at: 1, value: viewModel.averageGameScore > 0 ? String(format: "%.1f", viewModel.averageGameScore) : "-")
        updateStatValue(at: 2, value: "\(viewModel.highestGameScore)")

        let total = max(viewModel.totalAnime, 1)
        watchingStatView.configure(
            title: "Watching",
            count: viewModel.watchingCount,
            progress: Float(viewModel.watchingCount) / Float(total),
            color: UIColor.theme.primary
        )
        completedStatView.configure(
            title: "Completed",
            count: viewModel.completedCount,
            progress: Float(viewModel.completedCount) / Float(total),
            color: UIColor.theme.success
        )
        planStatView.configure(
            title: "Plan to Watch",
            count: viewModel.planToWatchCount,
            progress: Float(viewModel.planToWatchCount) / Float(total),
            color: UIColor.theme.accent
        )
    }

    private func updateStatValue(at index: Int, value: String) {
        guard index < statsStackView.arrangedSubviews.count,
              let valueLabel = statsStackView.arrangedSubviews[index].viewWithTag(100) as? UILabel else {
            return
        }
        valueLabel.text = value
    }

    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true

        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            picker.sourceType = .camera
            self?.present(picker, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            picker.sourceType = .photoLibrary
            self?.present(picker, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
            self?.navigateToSignIn()
        })
        present(alert, animated: true)
    }

    private func navigateToSignIn() {
        let signInVC = UINavigationController(rootViewController: SignInViewController())
        if let window = view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = signInVC
            }
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            profileImageView.image = image
            viewModel.updateProfileImage(image)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

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
