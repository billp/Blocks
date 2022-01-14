// TableViewRenderer.swift
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
import UIKit.UITableView
import DifferenceKit

final class TableViewRenderer: NSObject, TableViewRendererProtocol {
    // MARK: - Properties

    unowned var tableView: UITableView
    weak var delegate: TableViewRendererDelegate?
    var bundle: Bundle?

    var sections = [Section]()

    // MARK: - Private Properties

    private var registeredNibNames = Set<String>()
    private var registeredClassNames = Set<String>()

    // MARK: - Initializers

    init(tableView: UITableView, bundle: Bundle? = nil) {
        self.tableView = tableView
        self.bundle = bundle
        super.init()

        configureTableView(tableView)
    }

    // MARK: - Helpers

    private func configureTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self

        // Fix top and bottom empty space when UITableView is grouped
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNormalMagnitude))
    }

    private func registerNibNamesIfNeeded(sections: [Section]) {
        sections.forEach { section in
            registerHeaderFooterIfNeeded(for: section)
            registerElementsIfNeeded(for: section)
        }
    }

    /// Registers header, footer nib/class.
    private func registerHeaderFooterIfNeeded(for section: Section) {
        // Register Header/Footer nib/class
        [section.model.header, section.model.footer].compactMap({ $0 }).forEach { sectionElement in
            if let nibComponent = sectionElement as? NibComponent, !registeredNibNames.contains(nibComponent.nibName) {
                tableView.register(UINib(nibName: nibComponent.nibName, bundle: bundle),
                                   forHeaderFooterViewReuseIdentifier: sectionElement.reuseIdentifier)
                registeredNibNames.insert(nibComponent.nibName)
            } else if let classComponent = sectionElement as? ClassComponent {
                let className = String(describing: classComponent.viewClass)
                if !registeredClassNames.contains(className) {
                    tableView.register(classComponent.viewClass,
                                       forHeaderFooterViewReuseIdentifier: sectionElement.reuseIdentifier)
                    registeredClassNames.insert(className)
                }
            }
        }
    }

    /// Registers each element's nib/class.
    private func registerElementsIfNeeded(for section: Section) {
        // Register cell nibNames
        section.elements.forEach { row in
            if let nibComponent = row.component as? NibComponent,
               !registeredNibNames.contains(nibComponent.nibName) {
                tableView.register(UINib(nibName: nibComponent.nibName, bundle: bundle),
                                   forCellReuseIdentifier: row.component.reuseIdentifier)
                registeredNibNames.insert(nibComponent.nibName)
            } else if let classComponent = row.component as? ClassComponent {
                let className = String(describing: classComponent.viewClass)
                if !registeredClassNames.contains(className) {
                    tableView.register(classComponent.viewClass,
                                       forCellReuseIdentifier: row.component.reuseIdentifier)
                    registeredClassNames.insert(className)
                }
            }
        }
    }

    /// Helper for updating sections
    private func updateSections(_ newSections: [Section],
                                animation: UITableView.RowAnimation,
                                updateFlexibleHeightCellAsynchronusly: Bool = false) {
        registerNibNamesIfNeeded(sections: newSections)
        let changeset = StagedChangeset(source: sections, target: newSections)

        let completionClosure: ([Section]) -> Void = { [weak self] data in
            self?.sections = data
        }

        if animation == .none {
            UIView.performWithoutAnimation {
                tableView.reload(using: changeset,
                                 with: .none,
                                 interrupt: nil,
                                 setData: completionClosure)
            }
        } else {
            tableView.reload(using: changeset,
                             with: animation,
                             interrupt: nil,
                             setData: completionClosure)
        }
    }
}

// MARK: - TableViewRendererProtocol Implementation

extension TableViewRenderer {
    func setSections(_ newSections: [Section], animation: UITableView.RowAnimation) {
        updateSections(newSections, animation: animation)
    }

    func setRows(_ viewModels: [Component]) {
        let newSections = [
            Section(model: TableViewSection(sectionId: "1", header: nil, footer: nil),
                    elements: viewModels.map({ Block($0) }))

        ]
        updateSections(newSections, animation: .none)
    }

    func appendRow(_ viewModel: Component,
                   with animation: UITableView.RowAnimation) {
        let lastSectionIndex = sections.count > 0 ? sections.count - 1 : 0
        let lastRowIndex = sections[lastSectionIndex].elements.count

        var newSections = sections
        newSections[lastSectionIndex].elements.insert(Block(viewModel), at: lastRowIndex)
        updateSections(newSections, animation: animation)
    }

    func insertRows(_ viewModels: [Component],
                    at indexPath: IndexPath,
                    with animation: UITableView.RowAnimation) {
        var indexPaths = [IndexPath]()
        var newSections = sections

        viewModels.enumerated().forEach { index, viewModel in
            newSections[indexPath.section].elements.insert(Block(viewModel), at: indexPath.row + index)
            indexPaths.append(IndexPath(row: indexPath.row + index,
                                        section: indexPath.section))
        }

        registerNibNamesIfNeeded(sections: newSections)
        updateSections(newSections, animation: animation)
    }

    func insertRow(_ viewModel: Component,
                   at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation) {
        insertRows([viewModel], at: indexPath, with: animation)
    }

    func removeRows(from indexPaths: [IndexPath],
                    with animation: UITableView.RowAnimation) {
        var newSections = sections

        indexPaths.forEach { indexPath in
            newSections[indexPath.section].elements.remove(at: indexPath.row)
        }
        registerNibNamesIfNeeded(sections: newSections)
        updateSections(newSections, animation: animation)
    }

    func removeRow(from indexPath: IndexPath,
                   with animation: UITableView.RowAnimation) {
        removeRows(from: [indexPath], with: animation)
    }

    func removeModels<T>(ofType modelType: T.Type, animation: UITableView.RowAnimation) {
        var newSections = sections

        newSections.enumerated().forEach { index, section in
            let newElements = section.elements.filter({
                type(of: $0) != modelType
            })
            newSections[index].elements = newElements
        }

        setSections(newSections, animation: animation)
    }

    func expandFlexibleCells(animated: Bool, asynchronously: Bool) {
        if asynchronously {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.expandFlexibleCells(animated: animated)
            }
        } else {
            tableView.expandFlexibleCells(animated: animated)
        }
    }
}

// MARK: - Configure Views

extension TableViewRenderer {
    func headerView(for tableView: UITableView, inSection section: Int) throws -> UIView? {
        let sectionModel = sections[section].model

        guard let headerModel = sectionModel.header,
              let blockheader = sectionModel.blockHeader else {
            throw BlocksError.invalidModelClass
        }
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerModel.reuseIdentifier)
                as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass
        }

        header.configure(with: blockheader)
        tableView.setHeight(headerSection: section, view: header)
        return header
    }

    func footerView(for tableView: UITableView, inSection section: Int) throws -> UIView? {
        let sectionModel = sections[section].model

        guard let footerModel = sections[section].model.footer,
              let blockFooter = sectionModel.blockFooter else {
            throw BlocksError.invalidModelClass
        }
        guard let footer = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: footerModel.reuseIdentifier)
                as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass
        }

        footer.configure(with: blockFooter)
        return footer
    }

    func cellView(for tableView: UITableView, at indexPath: IndexPath) throws -> UITableViewCell? {
        let cellModel = sections[indexPath.section].elements[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.component.reuseIdentifier,
                                                       for: indexPath)
                as? UITableViewCell & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass
        }

        cellModel.component.beforeReuse()
        cell.setTableView(tableView)
        cell.configure(with: cellModel)
        return cell
    }
}

// MARK: - UITableView Delegate

extension TableViewRenderer: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        sections[section].elements.count
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        do {
            return try headerView(for: tableView, inSection: section)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        do {
            return try footerView(for: tableView, inSection: section)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        do {
            return try cellView(for: tableView, at: indexPath) ?? UITableViewCell()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: Set Heights

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].model.header == nil {
            return Double.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        if sections[section].model.footer == nil {
            return Double.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForFooterInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    // MARK: - User Events

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section].elements[indexPath.row]

        // Notify cell for didSelect action
        model.component.onSelect(deselectRow: { [weak self] animated in
            self?.tableView.deselectRow(at: indexPath, animated: animated)
        })

        // Notify delegate
        delegate?.didSelectRow(model,
                               tableView: tableView,
                               indexPath: indexPath)
    }
}
