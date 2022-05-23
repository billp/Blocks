// Section.swift
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

/// A Section is a group of components that includes a header, a footer and its items.
///
/// Find bellow an example of Section initialization:
///
///     Section(id: "section1",
///                 header: MyHeaderFooterComponent(title: "Header 1").asBlock,
///                 footer: MyHeaderFooterComponent(title: "Footer 1").asBlock,
///                 items: [
///                     MyLabelComponent(title: "Row 1"),
///                     MyLabelComponent(title: "Row 2"),
///                     MyLabelComponent(title: "Row 3"),
///                     MyButtonComponent(title: "Button 1", onTap: {
///                        print("Button 1 tapped")
///                     })
///                 ].asBlocks)
public struct Section: Hashable, Identifiable {
    /// A unique id of the hashable
    public let id: AnyHashable

    /// Tell Equatable to only take id into account.
    public static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }

    /// Tell hasher to use only the id of the Section.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// The header component of the Section.
    public var header: Block?
    /// The footer component of the Section.
    public var footer: Block?
    /// The row components of the Section.
    public var rows: [Block]?

    /// Default initializer of the Section.
    ///
    /// Parameters:
    ///    - id: A unique id of the section.
    ///    - header: The header component of the Section.
    ///    - footer: The footer component of the Section.
    ///    - items: The item components of the Section.
    public init(id: AnyHashable,
                header: Block? = nil,
                footer: Block? = nil,
                items: [Block]? = nil) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = items
    }
}
