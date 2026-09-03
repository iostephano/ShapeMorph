//
//  Morph.swift
//  ShapeMorph
//
//  Created by Stephano Portella on 03/04/25.
//

import CoreGraphics

/// La parte de "álgebra lineal" del morphing: emparejar los puntos de dos
/// figuras para que se correspondan y luego interpolar entre ellos.
enum Morph {

    /// Reordena `source` (una polilínea cerrada de N puntos) para que cada punto
    /// se corresponda lo mejor posible con el de `target` en el mismo índice.
    ///
    /// Prueba los N desplazamientos cíclicos y los dos sentidos de giro, y se
    /// queda con el que minimiza la suma de distancias al cuadrado. Sin esto, el
    /// punto 0 del cuadrado (una esquina) se emparejaría con el punto 0 del
    /// círculo (las 3 en punto) y la figura "giraría" durante la transición.
    static func aligned(_ source: [CGPoint], to target: [CGPoint]) -> [CGPoint] {
        guard source.count == target.count, source.count > 1 else { return source }
        let n = source.count

        func cost(_ candidate: [CGPoint]) -> CGFloat {
            var sum: CGFloat = 0
            for i in 0..<n {
                let dx = candidate[i].x - target[i].x
                let dy = candidate[i].y - target[i].y
                sum += dx * dx + dy * dy
            }
            return sum
        }

        var best = source
        var bestCost = cost(source)

        for orientation in [source, Array(source.reversed())] {
            for offset in 0..<n {
                let rotated = (0..<n).map { orientation[($0 + offset) % n] }
                let candidateCost = cost(rotated)
                if candidateCost < bestCost {
                    bestCost = candidateCost
                    best = rotated
                }
            }
        }
        return best
    }

    /// Interpola punto a punto entre `from` y `to`. `progress` se recorta a 0...1.
    static func interpolate(from: [CGPoint], to: [CGPoint], progress: CGFloat) -> [CGPoint] {
        guard from.count == to.count else { return to }
        let p = min(max(progress, 0), 1)
        return zip(from, to).map { a, b in
            CGPoint(x: a.x + (b.x - a.x) * p, y: a.y + (b.y - a.y) * p)
        }
    }

    /// Suavizado (smoothstep): entra y sale despacio, acelera en el medio.
    static func easeInOut(_ t: CGFloat) -> CGFloat {
        let t = min(max(t, 0), 1)
        return t * t * (3 - 2 * t)
    }
}
