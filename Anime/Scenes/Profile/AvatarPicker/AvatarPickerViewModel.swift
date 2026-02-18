//
//  AvatarPickerViewModel.swift
//  Anime
//
//  Created by elene malakmadze on 18.02.26.
//

import UIKit

final class AvatarPickerViewModel {

    let avatars: [AvatarOption] = [
        AvatarOption(symbolName: "person.fill", backgroundColor: .systemBlue),
        AvatarOption(symbolName: "star.fill", backgroundColor: .systemYellow),
        AvatarOption(symbolName: "heart.fill", backgroundColor: .systemPink),
        AvatarOption(symbolName: "moon.fill", backgroundColor: .systemPurple),
        AvatarOption(symbolName: "flame.fill", backgroundColor: .systemOrange),
        AvatarOption(symbolName: "bolt.fill", backgroundColor: .systemYellow),
        AvatarOption(symbolName: "leaf.fill", backgroundColor: .systemGreen),
        AvatarOption(symbolName: "sun.max.fill", backgroundColor: .systemOrange),
        AvatarOption(symbolName: "cloud.fill", backgroundColor: .systemCyan),
        AvatarOption(symbolName: "snowflake", backgroundColor: .systemTeal),
        AvatarOption(symbolName: "sparkles", backgroundColor: .systemIndigo),
        AvatarOption(symbolName: "hare.fill", backgroundColor: .systemBrown),
    ]

    var avatarCount: Int {
        avatars.count
    }

    func avatar(at index: Int) -> AvatarOption {
        avatars[index]
    }

    func renderAvatar(at index: Int) -> UIImage {
        let option = avatars[index]
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            option.backgroundColor.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()

            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium)
            if let symbol = UIImage(systemName: option.symbolName, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let symbolSize = symbol.size
                let symbolRect = CGRect(
                    x: (size.width - symbolSize.width) / 2,
                    y: (size.height - symbolSize.height) / 2,
                    width: symbolSize.width,
                    height: symbolSize.height
                )
                symbol.draw(in: symbolRect)
            }
        }
    }
}
