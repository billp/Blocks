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

/// Protocol for Component.
public protocol Component {
    /// Defines a unique id of the component.
    var componentId: String { get }

    /// Sets the reuseIdentifier of cell/header/footer.
    var reuseIdentifier: String { get }

    /// Called before cell/header/footer reuse.
    func beforeReuse()

    /// Called when cell is selected.
    ///
    /// Parameters:
    /// - deselectRow: A closure that deselects the selected row when called. It takes an animated (BOOL) value.
    func onSelect(deselectRow: (Bool) -> Void)
}

/// Protocol for Nib-based Components.
public protocol NibComponent: Component {
    /// Sets the nibName to automatically register as UINib.
    var nibName: String { get }
}

/// Protocol for Class-based Components.
public protocol ClassComponent: Component {
    /// Set the className to automatically register as Class.
    var viewClass: AnyClass { get }
}

/// Add default implementation for Component.
public extension Component {
    func beforeReuse() { }
    func onSelect(deselectRow: (Bool) -> Void) { }
}

/// Add default implementation Nib-based Components.
public extension NibComponent {
    // Use nibName value for reuseIdentifier.
    var reuseIdentifier: String {
        return nibName
    }
}

/// Add default implementation Class-based Components.
public extension ClassComponent {
    // Use viewClass type name for reuseIdentifier.
    var reuseIdentifier: String {
        return String(describing: type(of: viewClass))
    }
}
