//
//  Shape.swift
//  ShapeMorph
//
//  Created by Stephano Portella on 03/04/25.
//

import Foundation

/// Las figuras entre las que se puede morfar.
enum Shape: String, CaseIterable, Sendable {
    case square, rectangle, diamond, circle, heart, star

    var title: String {
        switch self {
        case .square: "Cuadrado"
        case .rectangle: "Rectángulo"
        case .diamond: "Rombo"
        case .circle: "Círculo"
        case .heart: "Corazón"
        case .star: "Estrella"
        }
    }
}
