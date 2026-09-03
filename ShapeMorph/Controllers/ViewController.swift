//
//  ViewController.swift
//  ShapeMorph
//
//  Created by Stephano Portella on 03/04/25.
//

import UIKit

final class ViewController: UIViewController {

    private let morphView = MorphingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        morphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(morphView)

        // Franja de color tras los botones para que el texto no quede sobre el
        // fondo blanco del lienzo.
        let controlBar = UIView()
        controlBar.backgroundColor = .systemBlue
        controlBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlBar)

        let buttons = makeShapeButtons()
        controlBar.addSubview(buttons)

        NSLayoutConstraint.activate([
            morphView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            morphView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            morphView.widthAnchor.constraint(equalToConstant: 300),
            morphView.heightAnchor.constraint(equalToConstant: 300),

            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controlBar.topAnchor.constraint(equalTo: buttons.topAnchor, constant: -16),

            buttons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    /// Dos filas de tres botones, todas con la misma tipografía. Se usan dos
    /// filas —en vez de encoger la fuente— porque seis botones en una sola no
    /// dejan espacio para "Rectángulo".
    private func makeShapeButtons() -> UIStackView {
        let shapes = Shape.allCases
        let midpoint = shapes.count / 2
        let rows = [Array(shapes[..<midpoint]), Array(shapes[midpoint...])].map { rowShapes -> UIStackView in
            let row = UIStackView(arrangedSubviews: rowShapes.map { makeButton(for: $0) })
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 8
            return row
        }

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func makeButton(for shape: Shape) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(shape.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        button.addAction(
            UIAction { [weak self] _ in self?.morphView.setTarget(shape) },
            for: .touchUpInside
        )
        return button
    }
}
