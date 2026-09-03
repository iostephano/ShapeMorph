//
//  ShapeLibraryTests.swift
//  ShapeMorphTests
//
//  Created by Stephano Portella on 03/09/26.
//

import Testing
import CoreGraphics
@testable import ShapeMorph

struct ShapeLibraryTests {

    private let rect = CGRect(x: 0, y: 0, width: 300, height: 300)

    private func gaps(_ points: [CGPoint]) -> [CGFloat] {
        (0..<points.count).map { i in
            let next = points[(i + 1) % points.count]
            return hypot(next.x - points[i].x, next.y - points[i].y)
        }
    }

    @Test("Every shape is represented with exactly `resolution` points", arguments: Shape.allCases)
    func pointCountIsUniform(shape: Shape) {
        #expect(ShapeLibrary.points(for: shape, in: rect).count == ShapeLibrary.resolution)
    }

    @Test("Every shape is centered on the rect", arguments: Shape.allCases)
    func shapeIsCentered(shape: Shape) {
        let points = ShapeLibrary.points(for: shape, in: rect)
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let midX = (xs.min()! + xs.max()!) / 2
        let midY = (ys.min()! + ys.max()!) / 2
        #expect(abs(midX - rect.midX) < 1)
        #expect(abs(midY - rect.midY) < 1)
    }

    @Test("Every shape fits inside the rect with a small margin", arguments: Shape.allCases)
    func shapeFitsInRect(shape: Shape) {
        let box = rect.insetBy(dx: -6, dy: -6)
        for point in ShapeLibrary.points(for: shape, in: rect) {
            #expect(box.contains(point))
        }
    }

    @Test("No point is farther from its neighbour than the arc-length step", arguments: Shape.allCases)
    func spacingHasNoGaps(shape: Shape) {
        let spacing = gaps(ShapeLibrary.points(for: shape, in: rect))
        let mean = spacing.reduce(0, +) / CGFloat(spacing.count)
        // Antes, corazón y estrella no pasaban por el remuestreo por arco y
        // dejaban huecos varias veces más grandes que la media. Ahora ninguno
        // pasa de ~1.5x (en las puntas afiladas la cuerda es más corta, eso sí
        // es esperable, por eso solo se comprueba el límite superior).
        #expect(spacing.allSatisfy { $0 < mean * 1.5 })
    }

    @Test("Resampling keeps the requested count and starts at the first vertex")
    func resampleBasics() {
        let square = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ]
        let resampled = ShapeLibrary.resample(square, to: 8)
        #expect(resampled.count == 8)
        #expect(resampled.first == CGPoint(x: 0, y: 0))

        let spacing = gaps(resampled)
        let mean = spacing.reduce(0, +) / CGFloat(spacing.count)
        #expect(spacing.allSatisfy { abs($0 - mean) < 0.0001 })
    }

    @Test("Resampling a degenerate polygon returns it unchanged")
    func resampleDegenerate() {
        #expect(ShapeLibrary.resample([CGPoint(x: 1, y: 1)], to: 10).count == 1)
    }
}
