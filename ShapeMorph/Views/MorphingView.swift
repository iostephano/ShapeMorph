//
//  MorphingView.swift
//  ShapeMorph
//
//  Created by Stephano Portella on 03/04/25.
//

import UIKit

/// Dibuja una figura rellena y la anima hacia otra con un `CADisplayLink`. La
/// geometría (generación de figuras, emparejamiento de puntos, interpolación)
/// vive en `ShapeLibrary` y `Morph`; aquí solo se lleva el estado de la
/// animación y el dibujo.
final class MorphingView: UIView {

    private let duration: CFTimeInterval = 0.6
    private let fillColor = UIColor.systemBlue

    private var currentShape: Shape = .square
    private var fromPoints: [CGPoint] = []
    private var toPoints: [CGPoint] = []
    private var lastSize: CGSize = .zero

    private var displayLink: CADisplayLink?
    private var progress: CGFloat = 1
    private var startTime: CFTimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // El `CADisplayLink` retiene su target: pausarlo al salir de la ventana
        // rompe ese ciclo y deja que la vista se libere.
        if window == nil {
            stopDisplayLink()
        } else if progress < 1 {
            startDisplayLink()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard fromPoints.isEmpty || bounds.size != lastSize else { return }

        // Al aparecer o cambiar de tamaño, se regenera la figura actual sin
        // animación.
        lastSize = bounds.size
        let points = ShapeLibrary.points(for: currentShape, in: bounds)
        fromPoints = points
        toPoints = points
        progress = 1
        stopDisplayLink()
        setNeedsDisplay()
    }

    func setTarget(_ shape: Shape) {
        guard shape != currentShape, bounds.width > 0 else { return }

        let target = ShapeLibrary.points(for: shape, in: bounds)
        fromPoints = Morph.aligned(currentInterpolatedPoints(), to: target)
        toPoints = target
        currentShape = shape

        progress = 0
        startTime = CACurrentMediaTime()
        startDisplayLink()
    }

    private func currentInterpolatedPoints() -> [CGPoint] {
        Morph.interpolate(from: fromPoints, to: toPoints, progress: Morph.easeInOut(progress))
    }

    private func startDisplayLink() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func step() {
        progress = min(max(CGFloat((CACurrentMediaTime() - startTime) / duration), 0), 1)
        if progress >= 1 {
            progress = 1
            fromPoints = toPoints
            stopDisplayLink()
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let points = currentInterpolatedPoints()
        guard points.count > 1 else { return }

        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.close()

        fillColor.setFill()
        path.fill()
    }
}
