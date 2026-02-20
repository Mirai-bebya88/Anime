//
//  SignInViewController.swift
//  Anime
//
//  Created by elene malakmadze on 02.02.26.
//

import UIKit

final class SignInViewController: UIViewController {

    private let viewModel = SignInViewModel()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "play.rectangle.fill")
        iv.tintColor = UIColor.theme.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AnimeApp"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your anime companion"
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.theme.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.backgroundColor = UIColor.theme.secondaryBackground
        return tf
    }()


    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor.theme.secondaryBackground
        return tf
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.theme.primary
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var toggleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        button.setTitleColor(UIColor.theme.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(toggleModeTapped), for: .touchUpInside)
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.error
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.theme.background
        navigationController?.setNavigationBarHidden(true, animated: false)

        let stackView = UIStackView(arrangedSubviews: [
            usernameTextField,
            passwordTextField,
            errorLabel,
            actionButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        view.addSubview(toggleModeButton)

        logoImageView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 60,
            width: 80,
            height: 80
        )
        logoImageView.centerX(in: view)

        titleLabel.anchor(
            top: logoImageView.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        subtitleLabel.anchor(
            top: titleLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 20,
            paddingTrailing: 20
        )

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        usernameTextField.anchor(height: 50)
        passwordTextField.anchor(height: 50)
        actionButton.anchor(height: 50)

        toggleModeButton.anchor(
            top: stackView.bottomAnchor,
            paddingTop: 20
        )
        toggleModeButton.centerX(in: view)
    }

    private func setupBindings() {
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }

        viewModel.onSuccess = { [weak self] _ in
            guard let scene = self?.view.window?.windowScene,
                  let sceneDelegate = scene.delegate as? SceneDelegate else { return }

            let mainTabBar = MainTabBarController()
            sceneDelegate.window?.rootViewController = mainTabBar
        }
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func actionButtonTapped() {
        hideError()
        viewModel.authenticate(
            username: usernameTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }

    @objc private func toggleModeTapped() {
        hideError()
        if viewModel.authMode == .signIn {
            viewModel.authMode = .signUp
            actionButton.setTitle("Sign Up", for: .normal)
            toggleModeButton.setTitle("Already have an account? Sign In", for: .normal)
        } else {
            viewModel.authMode = .signIn
            actionButton.setTitle("Sign In", for: .normal)
            toggleModeButton.setTitle("Don't have an account? Sign Up", for: .normal)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }


    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func hideError() {
        errorLabel.isHidden = true
    }
}
