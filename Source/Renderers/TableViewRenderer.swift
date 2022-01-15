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

open class TableViewRenderer: NSObject, TableViewRendererProtocol {
    // MARK: - Properties

    unowned var tableView: UITableView
    weak public var delegate: TableViewRendererDelegate?
    var bundle: Bundle?

    var sections = [Section]()

    // MARK: - Private Properties

    private var dataSource: UITableViewDiffableDataSource<Section, Block>!
    private var registeredNibNames = Set<String>()
    private var registeredClassNames = Set<String>()

    // MARK: - Initializers

    required public init(tableView: UITableView, bundle: Bundle? = nil) {
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

        configureDataSource(for: tableView)
    }

    private func configureDataSource(for tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<Section, Block>(
                        tableView: tableView,
                        cellProvider: { [unowned self] tableView, indexPath, _ in
            do {
                return try cellView(for: tableView, at: indexPath)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        })
    }

    private func applyChanges(with newSections: [Section]) {
        self.sections = newSections

        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Block>()
        newSnapshot.appendSections(newSections)
        newSections.forEach { section in
            newSnapshot.appendItems(section.items ?? [], toSection: section)
        }
        dataSource.apply(newSnapshot, animatingDifferences: true)

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
        [section.header, section.footer].compactMap({ $0 }).forEach { sectionElement in
            if let nibComponent = sectionElement.component as? AnyNibComponent,
                !registeredNibNames.contains(nibComponent.nibName) {
                tableView.register(UINib(nibName: nibComponent.nibName, bundle: bundle),
                                   forHeaderFooterViewReuseIdentifier: nibComponent.reuseIdentifier)
                registeredNibNames.insert(nibComponent.nibName)
            } else if let classComponent = sectionElement.component as? AnyClassComponent {
                let className = String(describing: classComponent.viewClass)
                if !registeredClassNames.contains(className) {
                    tableView.register(classComponent.viewClass,
                                       forHeaderFooterViewReuseIdentifier: classComponent.reuseIdentifier)
                    registeredClassNames.insert(className)
                }
            }
        }
    }

    /// Registers each element's nib/class.
    private func registerElementsIfNeeded(for section: Section) {
        // Register cell nibNames
        section.items?.forEach { row in
            if let nibComponent = row.component as? AnyNibComponent,
               !registeredNibNames.contains(nibComponent.nibName) {
                tableView.register(UINib(nibName: nibComponent.nibName, bundle: bundle),
                                   forCellReuseIdentifier: nibComponent.reuseIdentifier)
                registeredNibNames.insert(nibComponent.nibName)
            } else if let classComponent = row.component as? AnyClassComponent {
                let className = String(describing: classComponent.viewClass)
                if !registeredClassNames.contains(className) {
                    tableView.register(classComponent.viewClass,
                                       forCellReuseIdentifier: classComponent.reuseIdentifier)
                    registeredClassNames.insert(className)
                }
            }
        }
    }

    /// Helper for updating sections
    private func updateSections(_ newSections: [Section],
                                animation: UITableView.RowAnimation) {
        registerNibNamesIfNeeded(sections: newSections)
        applyChanges(with: newSections)
    }
}

// MARK: - TableViewRendererProtocol Implementation

public extension TableViewRenderer {
    func setSections(_ newSections: [Section], animation: UITableView.RowAnimation) {
        updateSections(newSections, animation: animation)
    }

    func setRows(_ viewModels: [Block]) {
        let newSections = [
            Section(items: viewModels)
        ]
        updateSections(newSections, animation: .none)
    }

    func appendRow(_ viewModel: Block,
                   with animation: UITableView.RowAnimation) {
        let lastSectionIndex = sections.count > 0 ? sections.count - 1 : 0
        let lastRowIndex = sections[lastSectionIndex].items?.count ?? 0

        var newSections = sections
        newSections[lastSectionIndex].items?.insert(viewModel, at: lastRowIndex)
        updateSections(newSections, animation: animation)
    }

    func insertRows(_ viewModels: [Block],
                    at indexPath: IndexPath,
                    with animation: UITableView.RowAnimation) {
        var indexPaths = [IndexPath]()
        var newSections = sections

        viewModels.enumerated().forEach { index, viewModel in
            newSections[indexPath.section].items?.insert(viewModel, at: indexPath.row + index)
            indexPaths.append(IndexPath(row: indexPath.row + index,
                                        section: indexPath.section))
        }

        registerNibNamesIfNeeded(sections: newSections)
        updateSections(newSections, animation: animation)
    }

    func insertRow(_ viewModel: Block,
                   at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation) {
        insertRows([viewModel], at: indexPath, with: animation)
    }

    func removeRows(from indexPaths: [IndexPath],
                    with animation: UITableView.RowAnimation) {
        var newSections = sections

        indexPaths.forEach { indexPath in
            newSections[indexPath.section].items?.remove(at: indexPath.row)
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
            let newElements = section.items?.filter({
                type(of: $0) != modelType
            })
            newSections[index].items = newElements
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
        let sectionModel = sections[section]
        guard let headerModel = sectionModel.header,
              let headerComponent = headerModel.component as? AnyComponent else {
            throw BlocksError.invalidModelClass
        }

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerComponent.reuseIdentifier)
        guard let header = header as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: headerComponent.reuseIdentifier)
        }
        header.configure(with: headerModel)
        tableView.setHeight(headerSection: section, view: header)
        return header
    }

    func footerView(for tableView: UITableView, inSection section: Int) throws -> UIView? {
        let sectionModel = sections[section]
        guard let footerModel = sectionModel.footer,
              let footerComponent = footerModel.component as? AnyComponent else {
            throw BlocksError.invalidModelClass
        }

        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerComponent.reuseIdentifier)
        guard let footer = footer as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: footerComponent.reuseIdentifier)
        }

        footer.configure(with: footerModel)
        return footer
    }

    func cellView(for tableView: UITableView, at indexPath: IndexPath) throws -> UITableViewCell? {
        guard let cellModel = sections[indexPath.section].items?[indexPath.row],
              let component = cellModel.component as? AnyComponent else {
            throw BlocksError.invalidModelClass
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: component.reuseIdentifier, for: indexPath)
        guard let cell = cell as? UITableViewCell & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: component.reuseIdentifier)
        }

        component.beforeReuse()
        cell.setTableView(tableView)
        cell.configure(with: cellModel)
        return cell
    }
}

// MARK: - UITableView Delegate

extension TableViewRenderer: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        sections[section].items?.count ?? 0
    }

    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        do {
            return try headerView(for: tableView, inSection: section)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        do {
            return try footerView(for: tableView, inSection: section)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        do {
            return try cellView(for: tableView, at: indexPath) ?? UITableViewCell()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: Set Heights

    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
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
        UITableView.automaticDimension
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
        UITableView.automaticDimension
    }

    // MARK: - User Events

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = sections[indexPath.section].items?[indexPath.row],
              let component = model.component as? AnyComponent else {
            return
        }

        // Notify cell for didSelect action
        component.onSelect(deselectRow: { [weak self] animated in
            self?.tableView.deselectRow(at: indexPath, animated: animated)
        })

        // Notify delegate
        delegate?.didSelectRow(model,
                               tableView: tableView,
                               indexPath: indexPath)
    }
}
