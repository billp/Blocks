// CellComponentViewProtocol.swift
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
import UIKit

private var tableViewHandle: UInt8 = 0

/// Protocol for UITableViewCell subclasses.
public protocol ComponentViewConfigurable: UIView {
    /// Required for cell configuration with the given model (e.g. setup MVVM Bindings)
    /// - Parameters:
    ///   - viewModel: The corresponding view model.
    func configure(with viewModel: any Component)

    /// Notifies the parent UITableView to update its cell heights.
    /// - Parameters:
    ///   - animated: If true, the UITableView will animate the cell height change.
    func updateCellHeight(animated: Bool)
}

/// Add default implementation for ComponentViewProtocol.
extension ComponentViewConfigurable {
    weak var renderer: TableViewRenderer? {
        get {
            objc_getAssociatedObject(self, &tableViewHandle) as? TableViewRenderer
        }
        set {
            objc_setAssociatedObject(self,
                                     &tableViewHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public func updateCellHeight(animated: Bool) {
        let updateHeights = {
            self.renderer?.tableView.beginUpdates()
            self.renderer?.tableView.endUpdates()
        }

        if animated {
            updateHeights()
        } else {
            UIView.performWithoutAnimation {
                updateHeights()
            }
        }
    }

    // Make configure optional
    func configure(with model: any Component) { }

    func setRenderer(_ renderer: TableViewRenderer) {
        self.renderer = renderer
    }
}
