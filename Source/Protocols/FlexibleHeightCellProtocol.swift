// FlexibleHeightCellProtocol.swift
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

import UIKit

private var heightConstraintHandle: UInt8 = 0
private var isFlexibleHandle: UInt8 = 0

enum FlexibleHeightConstants {
    static let leastAvailableCellHeight: CGFloat = 0.3
}

public protocol FlexibleViewHeightProtocol: AnyObject {
    var contentView: UIView { get }
    var heightConstraint: NSLayoutConstraint { get set }
    var isFlexible: Bool { get }

    func expandAsNeeded(tableView: UITableView, count: Int, animated: Bool)
}

public extension FlexibleViewHeightProtocol {
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

    var isFlexible: Bool {
        get {
            guard let isFlexible = objc_getAssociatedObject(self, &isFlexibleHandle) as? Bool else {
                self.isFlexible = true
                return self.isFlexible
            }
            return isFlexible
        }
        set {
            objc_setAssociatedObject(self,
                                     &isFlexibleHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func initializeHeightConstraint() -> NSLayoutConstraint {
        let blankView = UIView()
        blankView.translatesAutoresizingMaskIntoConstraints = false

        let heightConstraint = blankView
            .heightAnchor
            .constraint(equalToConstant: FlexibleHeightConstants.leastAvailableCellHeight)

        contentView.addSubview(blankView)

        NSLayoutConstraint.activate([
            heightConstraint,
            contentView.leftAnchor.constraint(equalTo: blankView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: blankView.rightAnchor),
            contentView.topAnchor.constraint(equalTo: blankView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: blankView.bottomAnchor)
        ])

        heightConstraint.priority = UILayoutPriority(900)

        return heightConstraint
    }

    // MARK: - Helpers

    /// It calculates the correct height for this cell based on UITableView's blank horizontal space.
    /// It should be called only after the rederer has completed rendering.
    func expandAsNeeded(tableView: UITableView, count: Int, animated: Bool) {
        var space = tableView.blankSpace / CGFloat(count)

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
