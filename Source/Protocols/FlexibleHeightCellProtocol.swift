// FlexibleHeightCellProtocol.swift
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

import UIKit

private var heightConstraintHandle: UInt8 = 0

enum FlexibleHeightConstants {
    static let leastAvailableCellHeight: CGFloat = 0.3
}

protocol FlexibleHeightCellProtocol: ComponentViewConfigurable {
    var heightConstraint: NSLayoutConstraint { get }
    func expandAsNeeded(tableView: UITableView, numberOfFlexibleCells: Int, animated: Bool)
}

extension FlexibleHeightCellProtocol where Self: UITableViewCell {
    var heightConstraint: NSLayoutConstraint {
        get {
            guard let heightConstraint = objc_getAssociatedObject(self, &heightConstraintHandle)
                    as? NSLayoutConstraint else {
                        let newHeightConstraint = initializeHeightConstraint()
                        self.heightConstraint = newHeightConstraint
                        return newHeightConstraint
                    }
            return heightConstraint
        }
        set {
            objc_setAssociatedObject(self,
                                     &heightConstraintHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func initializeHeightConstraint() -> NSLayoutConstraint {
        let heightConstraint = self.contentView.heightAnchor.constraint(
            equalToConstant: FlexibleHeightConstants.leastAvailableCellHeight)
        heightConstraint.priority = UILayoutPriority(900)
        heightConstraint.isActive = true
        return heightConstraint
    }

    // MARK: - Helpers

    /// It calculates the correct height for this cell based on UITableView's blank horizontal space.
    /// It should be called only after the rederer has completed rendering.
    func expandAsNeeded(tableView: UITableView, numberOfFlexibleCells: Int, animated: Bool) {
        var space = tableView.blankSpace / CGFloat(numberOfFlexibleCells)

        if space < 0 {
            space = FlexibleHeightConstants.leastAvailableCellHeight
        }
        executeAnimated(animated) { [weak self] in
            self?.heightConstraint.constant = space
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    private func executeAnimated(_ animated: Bool, block: () -> Void) {
        if !animated {
            UIView.performWithoutAnimation {
                block()
            }
        } else {
            block()
        }
    }
}
