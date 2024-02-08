// BlocksError.swift
//
// Copyright © 2021-2023 Vassilis Panagiotopoulos. All rights reserved.
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

/// Custom implementation of errors for Blocks.
enum BlocksError: Error {
    /// Thrown when invalid model class is provided.
    case invalidModelClass
    /// Thrown when invalid view class is provided.
    case invalidViewClass(reuseIdentifier: String)
    /// Thrown when the view model is not registered with a view.
    case viewModelNotRegistered
}

extension BlocksError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidModelClass:
            return NSLocalizedString("Invalid model class provided. Your model should conform to: " +
                                     "NibComponent or ClassComponent", comment: "Blocks")
        case .invalidViewClass(let reuseIdentifier):
            return NSLocalizedString("Your view class with reuseIdentifier '\(reuseIdentifier)' should conform to '" +
                                     String(describing: ComponentViewConfigurable.self) + "'", comment: "Blocks")
        case .viewModelNotRegistered:
            return NSLocalizedString("View model not registered", comment: "Blocks")
        }
    }
}

extension Error {
    func `as`<ErrorType>(_ type: ErrorType.Type) -> ErrorType {
        guard let error = self as? ErrorType else {
            fatalError("Unable to cast to \(type)")
        }
        return error
    }
}
