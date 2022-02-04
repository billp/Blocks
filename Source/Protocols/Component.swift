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

/// Protocol for AnyComponent.
public protocol AnyComponent {
    /// Sets the reuseIdentifier of cell/header/footer. (Optional)
    var reuseIdentifier: String { get }

    /// Called before cell/header/footer reuse. (Optional)
    func beforeReuse()
}

/// Protocol for Any Nib-based Components.
public protocol AnyNibComponent: AnyComponent {
    /// Sets the nibName to automatically register as UINib.
    var nibName: String { get }
}

/// Protocol for Any Class-based Components.
public protocol AnyClassComponent: AnyComponent {
    /// Set the className to automatically register as Class.
    var viewClass: AnyClass { get }
}

/// Protocol for Component.
public protocol Component: Hashable, AnyComponent {
    /// Quickly convert Component to a Block instance.
    var asBlock: Block { get }
}

/// Default implementation for Component.
public extension Component {
    var asBlock: Block {
        Block(self)
    }
}

/// Protocol for Nib-based Components.
public protocol NibComponent: Component, AnyNibComponent { }
/// Protocol for Class-based Components.
public protocol ClassComponent: Component, AnyClassComponent { }

/// Add default implementation for Component.
public extension Component {
    func beforeReuse() { }
}

/// Add default implementation Nib-based Components.
public extension NibComponent {
    // Use nibName value for reuseIdentifier.
    var reuseIdentifier: String {
        nibName
    }
}

/// Add default implementation Class-based Components.
public extension ClassComponent {
    // Use viewClass type name for reuseIdentifier.
    var reuseIdentifier: String {
        String(describing: viewClass.self)
    }
}
