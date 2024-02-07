//
//  MyLabelComponent.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import Blocks

struct MyLabelComponent: ClassComponent {
    var title: String

    var viewClass: AnyClass {
        LabelViewCell.self
    }
}
