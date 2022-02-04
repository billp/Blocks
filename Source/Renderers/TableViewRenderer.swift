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

import UIKit.UITableView

/// The renderer that uses UITableView as the container
/// of rendering components.
open class TableViewRenderer: NSObject, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties

    /// Holds an unowned reference of table view.
    unowned public var tableView: UITableView
    /// Defines a bundle that the xibs are loaded from.
    private var bundle: Bundle?

    /// The main data source of TableViewRenderer.
    /// This is where the view models are held.
    public var sections = [Section]()

    // MARK: - Private Properties

    /// Holds a reference of UITableViewDiffableDataSource.
    private var dataSource: UITableViewDiffableDataSource<Section, Block>!
    /// Holds a reference registered nib names in case of NibComponent.
    private var registeredNibNames = Set<String>()
    /// Holds a reference registered class names in case of ClassComponent.
    private var registeredClassNames = Set<String>()

    // MARK: - Initializers

    /// Default initializer of TableViewRenderer
    ///
    /// - Parameters:
    ///     - tableView: The associated with renderer table view.
    ///     - bundle: The bundle of the xib files.
    required public init(tableView: UITableView, bundle: Bundle? = nil) {
        self.tableView = tableView
        self.bundle = bundle
        super.init()

        configureTableView(tableView)
    }

    // MARK: - Helpers

    /// Sets the table view delegate to be used with renderer,
    /// and also configures the diffable data source.
    ///
    /// - Parameters:
    ///     - tableView: The associated with renderer table view.
    private func configureTableView(_ tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        // Fix top and bottom empty space when UITableView is grouped
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNormalMagnitude))

        dataSource = UITableViewDiffableDataSource<Section, Block>(
                        tableView: tableView,
                        cellProvider: { [unowned self] tableView, indexPath, _ in
            // Use the default method for providing cells
            self.tableView(tableView, cellForRowAt: indexPath)
        })
    }

    /// Applies changes to the dataSource by diffing old an new sections.
    ///
    /// - Parameters:
    ///     - newSections: The new sections that will be used for diffing.
    private func applyChanges(with newSections: [Section]) {
        self.sections = newSections

        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Block>()
        newSnapshot.appendSections(newSections)
        newSections.forEach { section in
            newSnapshot.appendItems(section.items ?? [], toSection: section)
        }

        if dataSource.defaultRowAnimation != .none {
            DispatchQueue.main.async {
                self.dataSource.apply(newSnapshot, animatingDifferences: true)
            }
        } else {
            self.dataSource.apply(newSnapshot, animatingDifferences: false)
        }
    }

    /// Used to register nibs or classes with the given sections for cells and headers/footers.
    /// It keeps track of the already registered nibs to avoid register them twice.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs will be registered on.
    private func registerNibsOrClassesIfNeeded(sections: [Section]) {
        sections.forEach { section in
            registerNibsOrClassesForHeadersFootersIfNeeded(for: section)
            registerNibsOrClassesForRowsIfNeeded(for: section)
        }
    }

    /// Registers nibs or classes for header and footers if needed.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs or classes will be registered on.
    private func registerNibsOrClassesForHeadersFootersIfNeeded(for section: Section) {
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

    /// Registers nibs or classes for rows if needed.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs or classes will be registered on.
    private func registerNibsOrClassesForRowsIfNeeded(for section: Section) {
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

    /// Helper method that updates sections by finding differences.
    ///
    /// - Parameters:
    ///     - newSections: The new sections that are used to find differences and apply changes.
    private func updateSections(_ newSections: [Section],
                                animation: UITableView.RowAnimation) {
        registerNibsOrClassesIfNeeded(sections: newSections)
        dataSource.defaultRowAnimation = animation
        applyChanges(with: newSections)
    }
}

// MARK: - TableViewRendererProtocol Implementation

extension TableViewRenderer: TableViewRendererProtocol {
    public func setSections(_ newSections: [Section], animation: UITableView.RowAnimation) {
        updateSections(newSections, animation: animation)
    }

    public func setRows(_ rows: [Block],
                        with animation: UITableView.RowAnimation = .none) {
        let newSections = [
            Section(id: "default",
                    items: rows)
        ]
        updateSections(newSections, animation: .none)
    }

    public func appendRow(_ row: Block,
                          atSectionIndex index: Int? = nil,
                          with animation: UITableView.RowAnimation = .none) {
        let lastSectionIndex = index ?? sections.count > 0 ? sections.count - 1 : 0
        let lastRowIndex = sections[lastSectionIndex].items?.count ?? 0

        var newSections = sections
        newSections[lastSectionIndex].items?.insert(row, at: lastRowIndex)
        updateSections(newSections, animation: animation)
    }

    public func insertRows(_ rows: [Block],
                           at indexPath: IndexPath,
                           with animation: UITableView.RowAnimation) {
        var indexPaths = [IndexPath]()
        var newSections = sections

        rows.enumerated().forEach { index, viewModel in
            newSections[indexPath.section].items?.insert(viewModel, at: indexPath.row + index)
            indexPaths.append(IndexPath(row: indexPath.row + index,
                                        section: indexPath.section))
        }

        updateSections(newSections, animation: animation)
    }

    public func insertRow(_ viewModel: Block,
                          at indexPath: IndexPath,
                          with animation: UITableView.RowAnimation) {
        insertRows([viewModel], at: indexPath, with: animation)
    }

    public func removeRows(from indexPaths: [IndexPath],
                           with animation: UITableView.RowAnimation) {
        var newSections = sections

        indexPaths.forEach { indexPath in
            newSections[indexPath.section].items?.remove(at: indexPath.row)
        }
        updateSections(newSections, animation: animation)
    }

    public func removeRow(from indexPath: IndexPath,
                          with animation: UITableView.RowAnimation) {
        removeRows(from: [indexPath], with: animation)
    }

    public func removeModels<T>(ofType modelType: T.Type, animation: UITableView.RowAnimation) {
        var newSections = sections

        newSections.enumerated().forEach { index, section in
            let newElements = section.items?.filter({
                !($0.component is T)
            })
            newSections[index].items = newElements
        }

        setSections(newSections, animation: animation)
    }

    public func expandFlexibleCellsIfNeeded(animated: Bool, asynchronously: Bool) {
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

extension TableViewRenderer {

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
}
