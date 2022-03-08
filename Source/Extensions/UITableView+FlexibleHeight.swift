// UITableView+FlexibleHeightCell.swift
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

private var totalCellsHeightHandle: UInt8 = 0
typealias FlexibleView = UIView & FlexibleViewHeightProtocol

extension UITableView {
    var cellHeights: [String: CGFloat] {
        get {
            return objc_getAssociatedObject(self, &totalCellsHeightHandle) as? [String: CGFloat] ?? [:]
        }
        set {
            objc_setAssociatedObject(self,
                                     &totalCellsHeightHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var totalCellHeight: CGFloat {
        cellHeights.values.reduce(0) { $0 + $1 }
    }

    func setHeight(indexPath: IndexPath, view: UIView) {
        guard !(view is FlexibleViewHeightProtocol) else {
            return
        }
        cellHeights[String(describing: indexPath)] = view.frame.height
    }

    func setHeight(headerSection: Int, view: UIView) {
        guard !(view is FlexibleViewHeightProtocol) else {
            return
        }
        let height = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        cellHeights["h" + String(describing: headerSection)] = height

    }
    func setHeight(footerSection: Int, view: UIView) {
        guard !(view is FlexibleViewHeightProtocol) else {
            return
        }
        let height = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        cellHeights["f" + String(describing: footerSection)] = height
    }

    func expandFlexibleViews(animated: Bool) {
        // Clear old heights
        cellHeights = [:]
        let flexibleHeightCells = self.indexPathsForVisibleRows?
            .compactMap({ self.cellForRow(at: $0) as? FlexibleView }) ?? []
        let flexibleHeightHeaders = self.indexPathsForVisibleRows?
            .compactMap({ self.headerView(forSection: $0.section) as? FlexibleView }) ?? []
        let flexibleHeightFooters = self.indexPathsForVisibleRows?
            .compactMap({ self.footerView(forSection: $0.section) as? FlexibleView }) ?? []

        let allViews = flexibleHeightCells + flexibleHeightHeaders + flexibleHeightFooters

        var uniqueViews = [FlexibleView]()
        allViews.forEach { view in
            if !uniqueViews.contains(where: { currentView in
                view == currentView
            }) {
                uniqueViews.append(view)
            }
        }

        // Iterate through all of sections and calculate the new heights
        updateTotalViewHeight()

        // Notify flexible cells to expand
        uniqueViews.forEach({ view in
            view.expandAsNeeded(tableView: self,
                                count: uniqueViews.count,
                                animated: animated)
        })
    }

    func updateTotalViewHeight() {
        // Iterate through all of sections and calculate the new heights
        (0..<self.numberOfSections).forEach { section in
            let headerView = headerView(forSection: section)
            let footerView = footerView(forSection: section)

            (0..<numberOfRows(inSection: section)).forEach { [weak self] row in
                let indexPath = IndexPath(row: row, section: section)
                let cell = cellForRow(at: indexPath) ?? UITableViewCell()
                self?.setHeight(indexPath: self?.indexPath(for: cell) ?? IndexPath(), view: cell)
            }

            self.setHeight(headerSection: section, view: headerView ?? UIView())
            self.setHeight(footerSection: section, view: footerView ?? UIView())
        }
    }

    var blankSpace: CGFloat {
        let bottomSafeArea = safeAreaInsets.bottom
        let blankSpace = frame.height - totalCellHeight - topbarHeight - bottomSafeArea
        return blankSpace
    }
}

// MARK: - Private Extensions

private extension UITableView {
    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.parentViewController?.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            return UIApplication.shared.statusBarFrame.size.height +
            (self.parentViewController?.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
