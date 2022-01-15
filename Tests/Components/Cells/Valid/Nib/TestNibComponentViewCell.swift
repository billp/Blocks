//
//  TestNibComponentViewCell.swift
//  Blocks
//
//  Created by Vassilis Panagiotopoulos on 16/1/22.
//

import UIKit
import Blocks

class TestNibComponentViewCell: UITableViewCell, ComponentViewConfigurable {
    @IBOutlet weak var testLabel: UILabel!

    func configure(with model: Block) {

    }
}
