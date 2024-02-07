//
//  MyButtonComponent.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import Blocks

struct MyButtonComponent: ClassComponent {
    var title: String
    var onTap: (() -> Void)?

    var viewClass: AnyClass {
        ButtonViewCell.self
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: MyButtonComponent, rhs: MyButtonComponent) -> Bool {
        lhs.title == rhs.title
    }
}
