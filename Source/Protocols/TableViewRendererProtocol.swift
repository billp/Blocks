// TableViewRendererProtocol.swift
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

import UIKit.UITableView

/// Protocol for UITableView implementation
public protocol TableViewRendererProtocol: UITableViewDataSource, UITableViewDelegate {
    /// The associated UITableView.
    var tableView: UITableView { get }
    /// The cell view models of the UITableView.
    var sections: [Section] { get }

    /// Sets and updates the sections of the renderer.
    /// Each section consists of header, footer and items.
    ///
    /// - Parameters:
    ///     - newSections: The new sections of the renderer.
    ///     - animation: The table view animation when instert/update/delete actions are needed.
    func setSections(_ sections: [Section], animation: UITableView.RowAnimation)

    /// Creates a default Section and sets its items to the given rows.
    /// It finally applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - rows: The new sections of the renderer.
    ///     - animation: The table view animation applied when update actions are made.
    func setRows(_ rows: [Block],
                 with animation: UITableView.RowAnimation)

    /// Appends a row to the given Section Index. If no Section Index is given,
    /// it appends the row to the last Section. It finally applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - newSections: The new sections of the renderer.
    ///     - animation: The table view animation applied when update actions are made.
    func appendRow(_ row: Block,
                   atSectionIndex index: Int?,
                   with animation: UITableView.RowAnimation)

    /// Inserts a row to the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - row: The row which will be inserted at the given index path.
    ///     - indexPath: The index path where the row will be inserted.
    ///     - animation: The table view animation applied when update actions are made.
    func insertRow(_ row: Block,
                   at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation)

    /// Inserts a rows to the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - rows: The rows which will be inserted at the given index path.
    ///     - indexPath: The index path where the row will be inserted.
    ///     - animation: The table view animation applied when update actions are made.
    func insertRows(_ rows: [Block],
                    at indexPath: IndexPath,
                    with animation: UITableView.RowAnimation)

    /// Removes the row from the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - indexPath: The index path where the row will be removed.
    ///     - animation: The table view animation applied when update actions are made.
    func removeRow(from indexPath: IndexPath,
                   with animation: UITableView.RowAnimation)

    /// Removes the rows with the given predicate and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - predicate: A closure that takes an element as its argument and
    ///     returns a Boolean value that indicates whether the passed element represents a match.
    ///     - animation: The table view animation applied when update actions are made.
    func removeRows(where predicate: (Block) -> Bool, animation: UITableView.RowAnimation)

    /// Default initializer.
    ///
    /// - Parameters:
    ///     - tableView: The table view that is used as a container of rendering Components
    ///     - bundle: The bundle of the xibs that are used by the Components. If this value
    ///               is nil, the default bundle is used.
    init(tableView: UITableView, bundle: Bundle?)
}
