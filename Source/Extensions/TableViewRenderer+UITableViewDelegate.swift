// TableViewRenderer+UITableViewDelegate.swift
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
import UIKit

extension TableViewRenderer: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Header/Footer/Cell Handling

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        sections[section].rows?.count ?? 0
    }

    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        do {
            return try headerView(for: tableView, inSection: section)
        } catch let error {
            Logger.error("%@", error.localizedDescription)
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        do {
            return try footerView(for: tableView, inSection: section)
        } catch let error {
            Logger.error("%@", error.localizedDescription)
            return nil
        }
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        do {
            return try cellView(for: tableView, at: indexPath) ?? UITableViewCell()
        } catch let error {
            Logger.error("%@", error.localizedDescription)
            return UITableViewCell()
        }
    }

    // MARK: Set Heights

    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let component = sections[indexPath.section].rows?[indexPath.row] else {
            return UITableView.automaticDimension
        }

        return estimatedHeightForRowComponent?(component) ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].header == nil {
            return Double.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let component = sections[section].header else {
            return UITableView.automaticDimension
        }

        return estimatedHeightForHeaderComponent?(component) ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
        if sections[section].footer == nil {
            return Double.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard let component = sections[section].footer else {
            return UITableView.automaticDimension
        }

        return estimatedHeightForFooterComponent?(component) ?? UITableView.automaticDimension
    }
}
