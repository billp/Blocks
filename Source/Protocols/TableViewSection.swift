// TableViewSection.swift
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

class TableViewSection: Differentiable {
    var sectionId: String

    var blockHeader: Block?
    var blockFooter: Block?

    var differenceIdentifier: String {
        sectionId
    }

    init(sectionId: String,
         header: Component? = nil,
         footer: Component? = nil) {
        self.sectionId = sectionId
        self.header = header
        self.footer = footer
    }

    var header: Component? {
        get {
            blockHeader?.component
        }
        set {
            if let header = newValue {
                blockHeader = Block(header)
            }
        }
    }
    var footer: Component? {
        get {
            blockFooter?.component
        }
        set {
            if let footer = newValue {
                blockFooter = Block(footer)
            }
        }
    }

    func isContentEqual(to source: TableViewSection) -> Bool {
        blockHeader == source.blockHeader && blockFooter == source.blockFooter
    }
}

typealias Section = ArraySection<TableViewSection, Block>
