// Collection+Block.swift
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

extension Collection where Element == AnyHashable {
    /// Convenience method for converting Component(s) to Boxes
    var asBoxes: [Box] {
        compactMap({ ($0 as? any Component)?.asBox })
    }
}

extension Collection where Element == any Component {
    /// Convenience method for converting Component(s) to Boxes
    var asAnyHashables: [AnyHashable] {
        compactMap({ $0 as? AnyHashable })
    }

    /// Convenience method for converting Component(s) to Bloxes
    var asBoxes: [Box] {
        self.asAnyHashables.asBoxes
    }
}
