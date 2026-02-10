//
//  UIColor+Theme.swift
//  Anime
//
//  Created by elene malakmadze on 02.02.26.
//

import UIKit

extension UIColor {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let primary = UIColor(red: 0.49, green: 0.23, blue: 0.93, alpha: 1.0)      // Purple (#7C3AED)
    let secondary = UIColor(red: 0.62, green: 0.09, blue: 0.30, alpha: 1.0)    // Burgundy (#9D174D)
    let background = UIColor.systemBackground
    let secondaryBackground = UIColor.secondarySystemBackground
    let accent = UIColor(red: 0.06, green: 0.73, blue: 0.51, alpha: 1.0)       // Emerald Green (#10B981)
    let textPrimary = UIColor.label
    let textSecondary = UIColor.secondaryLabel
    let success = UIColor(red: 0.06, green: 0.73, blue: 0.51, alpha: 1.0)      // Emerald Green
    let error = UIColor(red: 0.62, green: 0.09, blue: 0.30, alpha: 1.0)        // Burgundy for errors
    let cardBackground = UIColor.tertiarySystemBackground
}
