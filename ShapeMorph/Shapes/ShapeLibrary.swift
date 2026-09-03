//
//  ShapeLibrary.swift
//  ShapeMorph
//
//  Created by Stephano Portella on 03/04/25.
//

import CoreGraphics

/// Genera cada figura como una lista de puntos sobre su perímetro, todos
/// equiespaciados por longitud de arco. Que todas las figuras tengan el mismo
/// número de puntos y la misma densidad es lo que permite interpolar una con
/// otra sin que se deformen.
enum ShapeLibrary {

    /// Número de puntos con el que se representa cualquier figura.
    static let resolution = 64

    static func points(for shape: Shape, in rect: CGRect) -> [CGPoint] {
        centered(resample(outline(for: shape, in: rect), to: resolution), in: rect)
    }

    /// Reposiciona los puntos para que su caja contenedora quede centrada en
    /// `rect`. El corazón y la estrella no están centrados respecto a su centro
    /// "natural", así que sin esto se verían desplazados en el lienzo.
    private static func centered(_ points: [CGPoint], in rect: CGRect) -> [CGPoint] {
        guard !points.isEmpty else { return points }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let dx = rect.midX - (xs.min()! + xs.max()!) / 2
        let dy = rect.midY - (ys.min()! + ys.max()!) / 2
        return points.map { CGPoint(x: $0.x + dx, y: $0.y + dy) }
    }

    /// Vértices que definen el contorno de la figura (dados en sentido horario en
    /// coordenadas de pantalla). Para las curvas se muestrean lo bastante densos
    /// como para que el remuestreo por arco no pierda forma.
    private static func outline(for shape: Shape, in rect: CGRect) -> [CGPoint] {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.42

        switch shape {
        case .square:
            let s = radius
            return [
                CGPoint(x: center.x - s, y: center.y - s),
                CGPoint(x: center.x + s, y: center.y - s),
                CGPoint(x: center.x + s, y: center.y + s),
                CGPoint(x: center.x - s, y: center.y + s)
            ]

        case .rectangle:
            let halfWidth = radius * 0.62
            let halfHeight = radius * 1.1
            return [
                CGPoint(x: center.x - halfWidth, y: center.y - halfHeight),
                CGPoint(x: center.x + halfWidth, y: center.y - halfHeight),
                CGPoint(x: center.x + halfWidth, y: center.y + halfHeight),
                CGPoint(x: center.x - halfWidth, y: center.y + halfHeight)
            ]

        case .diamond:
            return [
                CGPoint(x: center.x, y: center.y - radius),
                CGPoint(x: center.x + radius, y: center.y),
                CGPoint(x: center.x, y: center.y + radius),
                CGPoint(x: center.x - radius, y: center.y)
            ]

        case .circle:
            return (0..<96).map { i in
                let angle = CGFloat(i) / 96 * 2 * .pi
                return CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
            }

        case .star:
            let inner = radius * 0.4
            return (0..<10).map { i in
                let angle = -CGFloat.pi / 2 + CGFloat(i) / 10 * 2 * .pi
                let r = i.isMultiple(of: 2) ? radius : inner
                return CGPoint(
                    x: center.x + cos(angle) * r,
                    y: center.y + sin(angle) * r
                )
            }

        case .heart:
            let scale = radius / 16
            return (0..<200).map { i in
                let t = CGFloat(i) / 200 * 2 * .pi
                let x = 16 * pow(sin(t), 3)
                let y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)
                return CGPoint(x: center.x + x * scale, y: center.y - y * scale)
            }
        }
    }

    /// Reparte una polilínea cerrada en `count` puntos equiespaciados por
    /// longitud de arco a lo largo de su perímetro.
    static func resample(_ polygon: [CGPoint], to count: Int) -> [CGPoint] {
        guard polygon.count >= 2, count > 0 else { return polygon }

        // Longitud acumulada en cada vértice, cerrando el último con el primero.
        var cumulative: [CGFloat] = [0]
        for i in 0..<polygon.count {
            let next = polygon[(i + 1) % polygon.count]
            cumulative.append(cumulative[i] + hypot(next.x - polygon[i].x, next.y - polygon[i].y))
        }
        let perimeter = cumulative[polygon.count]
        guard perimeter > 0 else { return Array(repeating: polygon[0], count: count) }

        let step = perimeter / CGFloat(count)
        var result: [CGPoint] = []
        result.reserveCapacity(count)

        var segment = 0
        for i in 0..<count {
            let target = CGFloat(i) * step
            while segment < polygon.count - 1 && cumulative[segment + 1] < target {
                segment += 1
            }
            let start = polygon[segment]
            let end = polygon[(segment + 1) % polygon.count]
            let segmentLength = cumulative[segment + 1] - cumulative[segment]
            let t = segmentLength > 0 ? (target - cumulative[segment]) / segmentLength : 0
            result.append(CGPoint(
                x: start.x + (end.x - start.x) * t,
                y: start.y + (end.y - start.y) * t
            ))
        }
        return result
    }
}
