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
protocol TableViewRendererProtocol: UITableViewDataSource, UITableViewDelegate {
    /// The associated UITableView.
    var tableView: UITableView { get }
    /// Renderer's delegate
    var delegate: TableViewRendererDelegate? { get set }
    /// The cell view models of the UITableView.
    var sections: [Section] { get }
    /// Sets an array of sections (replaces existing view models).
    func setSections(_ sections: [Section], animation: UITableView.RowAnimation)
    /// Sets an array of ViewModels (replaces existing view models).
    func setRows(_ viewModels: [Block])
    /// Appends a view model to the end of the UITableView with the given RowAnimation
    func appendRow(_ viewModel: Block,
                   with animation: UITableView.RowAnimation)
    /// Inserts a view model to the specified index with the given RowAnimation.
    func insertRow(_ viewModel: Block,
                   at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation)
    /// Inserts view models to the specified index with the given RowAnimation.
    func insertRows(_ viewModels: [Block],
                    at indexPath: IndexPath,
                    with animation: UITableView.RowAnimation)
    /// Removes a view model from the specified indexPaths with the given RowAnimation.
    func removeRow(from indexPath: IndexPath,
                   with animation: UITableView.RowAnimation)
    /// Removes a view model from the specified indexPaths with the given RowAnimation.
    func removeRows(from indexPaths: [IndexPath],
                    with animation: UITableView.RowAnimation)
    /// Removes rows of the given type, regardless section.
    func removeModels<T>(ofType type: T.Type, animation: UITableView.RowAnimation)
    /// Expands the flexible height cells as needed to fill the screen height.
    func expandFlexibleCells(animated: Bool, asynchronously: Bool)

    // Initializer
    init(tableView: UITableView, bundle: Bundle?)
}

/// Renderer delegate
public protocol TableViewRendererDelegate: AnyObject {
    /// Called when tableView:didSelectRowAtIndexPath: is called.
    func didSelectRow(_ viewModel: Block,
                      tableView: UITableView,
                      indexPath: IndexPath)
}
