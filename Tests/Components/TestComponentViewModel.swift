//
//  TestComponentViewModel.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 11/12/21.
//

@testable import Blocks

import Foundation

class TestComponentViewModel: ComponentViewModelClassInitializable {
    var viewClass: AnyClass {
        TestComponentCell.self
    }

    var componentId: String {
        "testComponent"
    }

    var reuseIdentifier: String {
        "testComponent"
    }

    func isComponentEqual(to source: ComponentViewModel) -> Bool {
        let model = source.value() as TestComponentViewModel
        return model.componentId == self.componentId
    }
}
