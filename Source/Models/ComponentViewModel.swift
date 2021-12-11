//
//  CellComponentViewModel.swift
//  RCCS
//
//  Created by Vassilis Panagiotopoulos on 10/10/21.
//

import Foundation
import DifferenceKit

class ComponentViewModel: ComponentViewModelProtocol, Differentiable, Equatable {
    static func == (lhs: ComponentViewModel, rhs: ComponentViewModel) -> Bool {
        lhs.isContentEqual(to: rhs)
    }

    var differenceIdentifier: String {
        guard let componentDifferentiable = self as? ComponentViewModelDifferentiable else {
            fatalError("\(type(of: self)) should comform to ComponentViewModelDifferentiable.")
        }
        return componentDifferentiable.componentId
    }

    func isContentEqual(to source: ComponentViewModel) -> Bool {
        guard let componentDifferentiable = self as? ComponentViewModelDifferentiable else {
            fatalError("\(type(of: self)) should comform to ComponentViewModelDifferentiable.")
        }

        return componentDifferentiable.isComponentEqual(to: source)
    }

    func beforeReuse() { }
}
