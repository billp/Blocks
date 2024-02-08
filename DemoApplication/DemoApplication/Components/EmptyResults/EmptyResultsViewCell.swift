//
//  EmptyResultsViewCell.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 16/2/24.
//

import UIKit
import Blocks

class EmptyResultsViewCell: UITableViewCell, ComponentViewConfigurable {
    @IBOutlet weak var resultLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    func configure(with viewModel: any Component) {
        let component = viewModel.as(EmptyResultsComponent.self)

        resultLabel.text = component.title
    }
}
