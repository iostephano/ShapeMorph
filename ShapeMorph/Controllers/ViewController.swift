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

        let buttons = makeShapeButtons()
        view.addSubview(buttons)

        NSLayoutConstraint.activate([
            morphView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            morphView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            morphView.widthAnchor.constraint(equalToConstant: 300),
            morphView.heightAnchor.constraint(equalToConstant: 300),

            buttons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func makeShapeButtons() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        for shape in Shape.allCases {
            let button = UIButton(type: .system)
            button.setTitle(shape.title, for: .normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.6
            button.addAction(
                UIAction { [weak self] _ in self?.morphView.setTarget(shape) },
                for: .touchUpInside
            )
            stack.addArrangedSubview(button)
        }
        return stack
    }
}
