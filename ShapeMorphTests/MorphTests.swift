//
//  MorphTests.swift
//  ShapeMorphTests
//
//  Created by Stephano Portella on 03/09/26.
//

import Testing
import CoreGraphics
@testable import ShapeMorph

struct MorphTests {

    private let rect = CGRect(x: 0, y: 0, width: 300, height: 300)

    private func cost(_ a: [CGPoint], _ b: [CGPoint]) -> CGFloat {
        zip(a, b).reduce(0) { sum, pair in
            let dx = pair.0.x - pair.1.x
            let dy = pair.0.y - pair.1.y
            return sum + dx * dx + dy * dy
        }
    }

    // MARK: - aligned

    @Test("Aligning identical point lists changes nothing")
    func alignIdentical() {
        let points = ShapeLibrary.points(for: .circle, in: rect)
        #expect(Morph.aligned(points, to: points) == points)
    }

    @Test("Alignment never increases the pairing cost")
    func alignNeverWorse() {
        let square = ShapeLibrary.points(for: .square, in: rect)
        let circle = ShapeLibrary.points(for: .circle, in: rect)
        #expect(cost(Morph.aligned(square, to: circle), circle) <= cost(square, circle))
    }

    @Test("Alignment strictly beats the naive pairing for square to circle")
    func alignBeatsNaive() {
        let square = ShapeLibrary.points(for: .square, in: rect)
        let circle = ShapeLibrary.points(for: .circle, in: rect)
        #expect(cost(Morph.aligned(square, to: circle), circle) < cost(square, circle))
    }

    @Test("Alignment recovers a cyclic shift of the target")
    func alignRecoversShift() {
        let circle = ShapeLibrary.points(for: .circle, in: rect)
        let shifted = (0..<circle.count).map { circle[($0 + 17) % circle.count] }
        #expect(cost(Morph.aligned(shifted, to: circle), circle) < 0.0001)
    }

    @Test("Alignment recovers a reversed winding order")
    func alignRecoversReversal() {
        let circle = ShapeLibrary.points(for: .circle, in: rect)
        let reversed = Array(circle.reversed())
        #expect(cost(Morph.aligned(reversed, to: circle), circle) < 0.0001)
    }

    @Test("Mismatched counts fall back to the target")
    func alignMismatch() {
        let a = [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1)]
        let b = [CGPoint(x: 5, y: 5)]
        #expect(Morph.aligned(a, to: b) == a)
    }

    // MARK: - interpolate

    @Test("Progress 0 returns the start, 1 returns the end, 0.5 the midpoint")
    func interpolateEndpoints() {
        let from = [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 20)]
        let to = [CGPoint(x: 10, y: 10), CGPoint(x: 30, y: 0)]
        #expect(Morph.interpolate(from: from, to: to, progress: 0) == from)
        #expect(Morph.interpolate(from: from, to: to, progress: 1) == to)
        #expect(Morph.interpolate(from: from, to: to, progress: 0.5) == [
            CGPoint(x: 5, y: 5),
            CGPoint(x: 20, y: 10)
        ])
    }

    @Test("Progress is clamped to 0...1")
    func interpolateClamps() {
        let from = [CGPoint(x: 0, y: 0)]
        let to = [CGPoint(x: 10, y: 10)]
        #expect(Morph.interpolate(from: from, to: to, progress: -1) == from)
        #expect(Morph.interpolate(from: from, to: to, progress: 2) == to)
    }

    @Test("Interpolating mismatched counts falls back to the target")
    func interpolateMismatch() {
        let to = [CGPoint(x: 1, y: 1)]
        #expect(Morph.interpolate(from: [], to: to, progress: 0.5) == to)
    }

    // MARK: - easeInOut

    @Test("easeInOut pins the endpoints and the midpoint and stays monotonic")
    func easing() {
        #expect(Morph.easeInOut(0) == 0)
        #expect(Morph.easeInOut(1) == 1)
        #expect(abs(Morph.easeInOut(0.5) - 0.5) < 0.0001)
        #expect(Morph.easeInOut(0.25) < Morph.easeInOut(0.5))
        #expect(Morph.easeInOut(-3) == 0)
        #expect(Morph.easeInOut(4) == 1)
    }
}
