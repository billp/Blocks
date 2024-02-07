//
//  MyButtonViewCell.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import UIKit
import Blocks

class ButtonViewCell: UITableViewCell, ComponentViewConfigurable {
    var model: MyButtonComponent!
    var button: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        addUIElements()
    }

    private func addUIElements() {
        button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        let padding: CGFloat = 10

        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -padding),
        ])
    }

    @objc func buttonAction() {
        model.onTap?()
    }

    func configure(with model: Block) {
        let model = model.as(MyButtonComponent.self)
        button.setTitle(model.title, for: .normal)

        self.model = model

    }
}
