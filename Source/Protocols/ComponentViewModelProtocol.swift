// ComponentViewModelProtocol.swift
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

/// Protocol for base ComponentViewModel.
public protocol ComponentViewModelProtocol {
    /// Get the model with its actual object type.
    func value<T>() -> T

    /// Called before cell/header/footer reuse.
    func beforeReuse()
}

/// Selectable protocol that enables didSelect functionality.
public protocol ComponentViewModelSelectable {
    /// Called when cell is selected.
    ///
    /// Parameters:
    /// - deselectRow: A closure that deselects the row when called. It takes an animated (BOOL) value.
    func onSelect(deselectRow: (Bool) -> Void)
}

/// Protocol which defines that the ListComponentViewModel is reusable.
public protocol ComponentViewModelReusable {
    /// Set the reuseIdentifier of cell/header/footer.
    var reuseIdentifier: String { get }
}

/// Protocol which defines that the ListComponentViewModel is Nib initializable.
public protocol ComponentViewModelNibInitializableProtocol {
    /// Set the nibName to automatically register as UINib.
    var nibName: String { get }
}

/// Protocol which defines that the ListComponentViewModel is Class initializable.
public protocol ComponentViewModelClassInitializableProtocol {
    /// Set the className to automatically register as Class.
    var viewClass: AnyClass { get }
}

/// Protocol which bridges the component with the DifferenceKit
public protocol ComponentViewModelDifferentiable {
    /// Defines a unique id of the component.
    var componentId: String { get }
    /// Defines how the components can be compared.
    func isComponentEqual(to source: ComponentViewModel) -> Bool
}

public extension ComponentViewModelProtocol {
    /// Returns model value casted to the given type.
    func value<T>() -> T {
        if let viewModel = self as? T {
            return viewModel
        }

        fatalError("Invalid model class \(T.self). Please check the class type!")
    }
}
