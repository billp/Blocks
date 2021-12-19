// ComponentViewModel.swift
//
// Copyright © 2021-2022 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import DifferenceKit

open class ComponentViewModel: ComponentViewModelProtocol, Differentiable, Equatable {
    public static func == (lhs: ComponentViewModel, rhs: ComponentViewModel) -> Bool {
        lhs.isContentEqual(to: rhs)
    }

    public var differenceIdentifier: String {
        guard let componentDifferentiable = self as? ComponentViewModelDifferentiable else {
            fatalError("\(type(of: self)) should comform to ComponentViewModelDifferentiable.")
        }
        return componentDifferentiable.componentId
    }

    public func isContentEqual(to source: ComponentViewModel) -> Bool {
        guard let componentDifferentiable = self as? ComponentViewModelDifferentiable else {
            fatalError("\(type(of: self)) should comform to ComponentViewModelDifferentiable.")
        }

        return componentDifferentiable.isComponentEqual(to: source)
    }

    public func beforeReuse() { }
    public init() { }
}
