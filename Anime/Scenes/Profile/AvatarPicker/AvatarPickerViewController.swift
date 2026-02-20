//
//  AvatarPickerViewController.swift
//  Anime
//
//  Created by elene malakmadze on 18.02.26.
//

import UIKit

struct AvatarOption {
    let symbolName: String
    let backgroundColor: UIColor
}

final class AvatarPickerViewController: UIViewController {

    var onAvatarSelected: ((UIImage) -> Void)?

    private let viewModel = AvatarPickerViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Avatar"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(AvatarCollectionViewCell.self, forCellWithReuseIdentifier: AvatarCollectionViewCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.theme.background

        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 24,
            paddingTrailing: 24
        )

        collectionView.anchor(
            top: titleLabel.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )
    }

}

extension AvatarPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.avatarCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCollectionViewCell.reuseIdentifier, for: indexPath) as? AvatarCollectionViewCell else {
            return UICollectionViewCell()
        }
        let avatar = viewModel.avatar(at: indexPath.item)
        cell.configure(symbolName: avatar.symbolName, backgroundColor: avatar.backgroundColor)
        return cell
    }
}

extension AvatarPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = viewModel.renderAvatar(at: indexPath.item)
        onAvatarSelected?(image)
        dismiss(animated: true)
    }
}

extension AvatarPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 24 * 2 + 16 * 3
        let width = (collectionView.bounds.width - padding) / 4
        return CGSize(width: width, height: width)
    }
}
