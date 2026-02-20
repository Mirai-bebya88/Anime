//
//  AvatarCell.swift
//  Anime
//
//  Created by elene malakmadze on 18.02.26.
//

import UIKit

final class AvatarCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "AvatarCell"

    private let circleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private let symbolImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
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
        circleView.layer.cornerRadius = circleView.bounds.width / 2
    }

    private func setupUI() {
        contentView.addSubview(circleView)
        circleView.addSubview(symbolImageView)

        circleView.fillSuperview()
        symbolImageView.center(in: circleView)
        symbolImageView.anchor(width: 32, height: 32)
    }

    func configure(symbolName: String, backgroundColor: UIColor) {
        circleView.backgroundColor = backgroundColor
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        symbolImageView.image = UIImage(systemName: symbolName, withConfiguration: config)
    }
}
