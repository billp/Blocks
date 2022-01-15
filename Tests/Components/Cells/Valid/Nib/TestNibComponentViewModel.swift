//
//  TestNibComponentViewModel.swift
//  Blocks
//
//  Created by Vassilis Panagiotopoulos on 16/1/22.
//

import Foundation
import Blocks

struct TestNibComponentViewModel: NibComponent {
    var componentId: AnyHashable = UUID()

    var nibName: String {
        String(describing: TestNibComponentViewCell.self)
    }
}
