// Spacer.swift
//
// Copyright © 2021-2024 Vassilis Panagiotopoulos. All rights reserved.
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

/// Specifies a type of the Spacer.
public enum SpacerType: Hashable, Equatable {
    private enum Constants {
        static let flexibleValue: Float = -1
    }

    /// Automatically adjusts height to fill the blank space.
    case flexible
    /// Specifies a fixed height constant for the spacer.
    case fixed(Float)

    /// Convert enum case to float.
    var value: Float {
        switch self {
        case .flexible:
            return Constants.flexibleValue
        case .fixed(let float):
            return float
        }
    }
}

/// Defines a special type of Component which defines a vertical spacer based on a type.
/// The type can be either flexible (expands up to the blank space) or fixed (defines a specific height).
public struct Spacer: Component {
    var id: UUID = .init()

    var isDragNDropSpacer = false

    /// The type of the spacer.
    var type: SpacerType

    public init(type: SpacerType) {
        self.type = type
    }
}
