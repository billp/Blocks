//
//  MyHeaderFooterView.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import UIKit
import Blocks

class MyHeaderFooterView: UITableViewHeaderFooterView {
    var label: UILabel!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addUIElements()
    }

    private func addUIElements() {
        label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .blue

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension MyHeaderFooterView: ComponentViewConfigurable {
    func configure(with model: Block) {
        let model = model.as(MyHeaderFooterComponent.self)
        label.text = model.title
    }
}
