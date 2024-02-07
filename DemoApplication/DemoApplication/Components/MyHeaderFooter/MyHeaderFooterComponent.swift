//
//  MyHeaderFooterComponent.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import Foundation
import Blocks

struct MyHeaderFooterComponent: ClassComponent {
    var title: String

    var viewClass: AnyClass {
        MyHeaderFooterView.self
    }
}
