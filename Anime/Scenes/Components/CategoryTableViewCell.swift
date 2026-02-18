//
//  CategoryTableViewCell.swift
//  Anime
//
//  Created by elene malakmadze on 12.02.26.
//

import UIKit

protocol CategoryTableViewCellDelegate: AnyObject {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectAnime anime: Anime)
}

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"

    weak var delegate: CategoryTableViewCellDelegate?
    private var animeList: [Anime] = []

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.theme.textPrimary
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 220)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(AnimeCollectionViewCell.self, forCellWithReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
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

        contentView.addSubview(categoryLabel)
        contentView.addSubview(collectionView)

        categoryLabel.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16
        )

        collectionView.anchor(
            top: categoryLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 12,
            paddingBottom: 8,
            height: 220
        )
    }

    func configure(with title: String, animeList: [Anime]) {
        categoryLabel.text = title
        self.animeList = animeList
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
}

extension CategoryTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCollectionViewCell.reuseIdentifier, for: indexPath) as? AnimeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: animeList[indexPath.item])
        return cell
    }
}


extension CategoryTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoryTableViewCell(self, didSelectAnime: animeList[indexPath.item])
    }
}
