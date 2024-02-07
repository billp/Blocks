//
//  LabelViewCell.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import Blocks
import UIKit

class LabelViewCell: UITableViewCell, ComponentViewConfigurable {
    func configure(with model: Block) {
        let model = model.as(MyLabelComponent.self)
        textLabel?.text = model.title
        selectionStyle = .none
    }
}
