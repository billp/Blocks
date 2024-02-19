// TableViewRenderer.swift
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
//
// swiftlint:disable file_length

import UIKit.UITableView
import SwiftUI

/// The renderer that uses UITableView as the container
/// of rendering components.
open class TableViewRenderer: NSObject {
    // MARK: - Properties

    /// Holds an unowned reference of table view.
    unowned public var tableView: UITableView
    /// Defines a bundle that the xibs are loaded from.
    private var bundle: Bundle?

    /// Provides closures for computing estimations
    public var estimatedHeightForRowComponent: ((any Component) -> CGFloat)?
    public var estimatedHeightForHeaderComponent: ((any Component) -> CGFloat)?
    public var estimatedHeightForFooterComponent: ((any Component) -> CGFloat)?

    /// The main data source of TableViewRenderer.
    /// This is where the view models are held.
    public var sections = [Section]()

    // MARK: - Private Properties

    /// Holds a reference of UITableViewDiffableDataSource.
    private var dataSource: UITableViewDiffableDataSource<Section, Box>!
    /// Holds a reference registered nib names in case of NibComponent.
    internal var registeredNibNames = Set<String>()
    /// Holds a reference registered class names in case of ClassComponent.
    internal var registeredClassNames = Set<String>()

    // Dictionary to hold the association between component types
    // and nib names
    internal var nibRegistrations: [ObjectIdentifier: String] = [:]
    // Dictionary to hold the association between component types
    // and class types
    internal var classRegistrations: [ObjectIdentifier: AnyClass] = [:]
    // Dictionary to hold the association between component types
    // and SwiftUI types
    internal var swiftUIRegistrations: [ObjectIdentifier: any ComponentSwiftUIViewConfigurable.Type] = [:]

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

        tableView.dragInteractionEnabled = true // Enable drag
        tableView.dropDelegate = self
        tableView.dragDelegate = self

        // Register Spacer
        register(viewModelType: Spacer.self, classType: SpacerCell.self)

        // Remove strage empty space on occured in iOS Version >= 15.0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = .leastNormalMagnitude
        }

        dataSource = UITableViewDiffableDataSource<Section, Box>(
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

        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Box>()
        newSnapshot.appendSections(newSections)
        newSections.forEach { section in
            newSnapshot.appendItems(section.rows?.asBoxes ?? [], toSection: section)
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
            registerSwiftUIClassesIfNeeded(for: section)
        }
    }

    /// Registers nibs or classes for header and footers if needed.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs or classes will be registered on.
    private func registerNibsOrClassesForHeadersFootersIfNeeded(for section: Section) {
        // Register Header/Footer nib/class
        [section.header, section.footer]
            .compactMap({ $0 })
            .forEach { headerFooter in
                if let nibName = try? self.nibName(for: headerFooter),
                   !registeredNibNames.contains(nibName) {
                    tableView.register(UINib(nibName: nibName, bundle: bundle),
                                       forHeaderFooterViewReuseIdentifier: nibName)
                    registeredNibNames.insert(nibName)
                } else if let viewClass = try? self.viewClass(for: headerFooter),
                          !registeredClassNames.contains(String(describing: viewClass.self)) {
                    tableView.register(viewClass,
                                       forHeaderFooterViewReuseIdentifier: String(describing: viewClass.self))
                    registeredClassNames.insert(String(describing: viewClass.self))
                }

                let reuseIdentifier = try? reuseIdentifier(for: headerFooter)
                if reuseIdentifier == nil {
                    fatalError("\(type(of: headerFooter)) is not registered")
                }
        }
    }

    /// Registers nibs or classes for rows if needed.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs or classes will be registered on.
    private func registerNibsOrClassesForRowsIfNeeded(for section: Section) {
        // Register cell nibNames
        section.rows?.forEach { row in
            if let nibName = try? nibName(for: row),
               !registeredNibNames.contains(nibName) {
                tableView.register(UINib(nibName: nibName, bundle: bundle),
                                   forCellReuseIdentifier: nibName)
                registeredNibNames.insert(nibName)
            } else if let viewClass = try? self.viewClass(for: row),
                      !registeredClassNames.contains(String(describing: viewClass)) {
                tableView.register(viewClass,
                                   forCellReuseIdentifier: String(describing: viewClass))
                registeredClassNames.insert(String(describing: viewClass))
            }

            let reuseIdentifier = try? reuseIdentifier(for: row)
            if reuseIdentifier == nil {
                fatalError("\(type(of: row)) is not registered")
            }
        }
    }

    /// Registers nibs or classes for header and footers if needed.
    ///
    /// - Parameters:
    ///     - sections: The sections that the nibs or classes will be registered on.
    private func registerSwiftUIClassesIfNeeded(for section: Section) {
        let allComopnents = [section.header, section.footer] + (section.rows ?? [])

        // Register Header/Footer nib/class
        allComopnents
            .compactMap({ $0 })
            .forEach { component in
                if let swiftUIView = try? self.swiftUIView(for: component),
                   !registeredClassNames.contains(String(describing: swiftUIView)) {
                    tableView.register(SwiftUIHostingTableViewCell.self,
                                       forCellReuseIdentifier: String(describing: type(of: swiftUIView)))
                    tableView.register(SwiftUIHostingTableHeaderFooterView.self,
                                       forHeaderFooterViewReuseIdentifier: String(describing: type(of: swiftUIView)))
                }

                let reuseIdentifier = try? reuseIdentifier(for: component)
                if reuseIdentifier == nil {
                    fatalError("\(type(of: component)) is not registered")
                }
            }
    }

    /// Helper method that updates sections by finding differences and applying changes to the table view.
    ///
    /// This method performs several operations to update the table view sections:
    /// 1. Registers any nibs or classes that are needed for new sections. 
    /// This ensures that all cell types used in the new sections are available to the table view.
    /// 2. Sets spacer identifiers for sections if needed. 
    /// This is typically used for managing spacing or separator cells within sections.
    /// 3. Updates the default row animation for the data source. 
    /// This animation is used for insertions, deletions, and updates that are applied to the sections.
    /// 4. Applies changes to the table view based on the new sections. 
    /// This step involves calculating the differences between 
    /// the current and new sections and applying those differences to
    /// update the table view.
    /// 5. Expands flexible views within the table view if needed.
    /// If there are any views within the table view sections that 
    /// need to adjust their size or layout based on the new content,
    /// this step ensures those adjustments are made. The expansion can
    /// be animated depending on the animation parameter.
    ///
    /// - Parameters:
    ///   - newSections: The new sections that are used to find differences 
    ///   and apply changes. This array of `Section` objects represents the
    ///   updated state of the table view sections.
    ///   - animation: The animation to use when applying updates to the table view. 
    ///   If `.none` is specified, updates will not be animated.
    private func applySectionsUpdate(_ newSections: [Section], animation: UITableView.RowAnimation) {
        registerNibsOrClassesIfNeeded(sections: newSections)
        dataSource.defaultRowAnimation = animation
        applyChanges(with: newSections)
        expandFlexibleViewsIfNeeded(animated: animation != .none)
    }

    /// Creates an IndexPath mapping for each component for quick access.
    ///
    private func createIndexPathMapping() -> [IndexPath: any Component] {
        var result = [IndexPath: any Component]()
        sections.enumerated().forEach { sectionIndex, section in
            section.rows?.enumerated().forEach { rowIndex, block in
                result[IndexPath(row: rowIndex, section: sectionIndex)] = block
            }
        }
        return result
    }

    /// Expands the flexible cells if needed.
    /// Flexible cells are special type of cells which can be expanded in height as needed to fill the blank space.
    ///
    /// - Parameters:
    ///     - animated: True to animate while expanding.
    private func expandFlexibleViewsIfNeeded(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.expandFlexibleViews(animated: animated)
        }
    }
}

// MARK: - TableViewRendererProtocol Implementation

extension TableViewRenderer: TableViewRendererProtocol {
    public func register(viewModelType: any Component.Type, nibName: String) {
        let typeId = ObjectIdentifier(viewModelType)
        nibRegistrations[typeId] = nibName
    }

    public func register(viewModelType: any Component.Type, classType: AnyClass) {
        let typeId = ObjectIdentifier(viewModelType)
        classRegistrations[typeId] = classType
    }

    public func register<View: ComponentSwiftUIViewConfigurable>(viewModelType: any Component.Type,
                                                                 viewType: View.Type) {
        let typeId = ObjectIdentifier(viewModelType)
        swiftUIRegistrations[typeId] = viewType
    }

    // MARK: Sections Update

    public func updateSections(_ newSections: [Section],
                               animation: UITableView.RowAnimation) {
        applySectionsUpdate(newSections, animation: animation)
    }

    public func insertSection(_ section: Section,
                              at index: Int,
                              with animation: UITableView.RowAnimation = .none) {
        var newSections = sections
        newSections.insert(section, at: index)
        applySectionsUpdate(newSections, animation: animation)
    }

    public func insertSections(_ newSections: [Section],
                               at startIndex: Int,
                               with animation: UITableView.RowAnimation = .none) {
        var updatedSections = sections
        updatedSections.insert(contentsOf: newSections, at: startIndex)
        applySectionsUpdate(updatedSections, animation: animation)
    }

    public func appendSection(_ section: Section,
                              with animation: UITableView.RowAnimation = .none) {
        var newSections = sections
        newSections.append(section)
        applySectionsUpdate(newSections, animation: animation)
    }

    public func appendSections(_ newSections: [Section],
                               with animation: UITableView.RowAnimation = .none) {
        var updatedSections = sections
        updatedSections.append(contentsOf: newSections)
        applySectionsUpdate(updatedSections, animation: animation)
    }

    public func removeSection(at index: Int,
                              with animation: UITableView.RowAnimation = .none) {
        var newSections = sections
        guard index < newSections.count else { return }
        newSections.remove(at: index)
        applySectionsUpdate(newSections, animation: animation)
    }

    public func removeSections(where shouldBeRemoved: (Section) -> Bool,
                               with animation: UITableView.RowAnimation = .none) {
        var newSections = sections
        newSections.removeAll(where: shouldBeRemoved)
        applySectionsUpdate(newSections, animation: animation)
    }

    // MARK: Rows Update

    public func updateRows(_ rows: [any Component],
                           with animation: UITableView.RowAnimation = .none) {
        let newSections = [
            Section(id: "0", rows: rows)
        ]
        applySectionsUpdate(newSections, animation: .none)
    }

    public func appendRow(_ row: any Component,
                          atSectionIndex index: Int? = nil,
                          with animation: UITableView.RowAnimation = .none) {
        let lastSectionIndex = index ?? sections.count > 0 ? sections.count - 1 : 0
        let lastRowIndex = sections[lastSectionIndex].rows?.count ?? 0

        var newSections = sections
        newSections[lastSectionIndex].rows?.insert(row, at: lastRowIndex)
        applySectionsUpdate(newSections, animation: animation)
    }

    public func insertRows(_ rows: [any Component],
                           at indexPath: IndexPath,
                           with animation: UITableView.RowAnimation) {
        var indexPaths = [IndexPath]()
        var newSections = sections

        rows.enumerated().forEach { index, viewModel in
            newSections[indexPath.section].rows?.insert(viewModel, at: indexPath.row + index)
            indexPaths.append(IndexPath(row: indexPath.row + index,
                                        section: indexPath.section))
        }

        applySectionsUpdate(newSections, animation: animation)
    }

    public func insertRow(_ viewModel: any Component,
                          at indexPath: IndexPath,
                          with animation: UITableView.RowAnimation) {
        insertRows([viewModel], at: indexPath, with: animation)
    }

    public func removeRow(at indexPath: IndexPath,
                          with animation: UITableView.RowAnimation) {
        var newSections = sections
        newSections[indexPath.section].rows?.remove(at: indexPath.row)
        applySectionsUpdate(newSections, animation: animation)
    }

    public func removeRows(where predicate: (any Component) -> Bool,
                           animation: UITableView.RowAnimation) {
        var componentsToRemove = [any Component]()
        let allRows = createIndexPathMapping().map({ $1 })

        allRows.forEach { item in
            if predicate(item) {
                componentsToRemove.append(item)
            }
        }

        while !componentsToRemove.isEmpty {
            let currentComponent = componentsToRemove.removeFirst()
            let currentMappings = createIndexPathMapping()

            if let mapping = currentMappings.first(where: { $1.asBox == currentComponent.asBox }) {
                removeRow(at: mapping.key, with: animation)
            }
        }
    }
}

// MARK: - Configure Views

extension TableViewRenderer: UITableViewDelegate,
                             UITableViewDataSource {
    func headerView(for tableView: UITableView, inSection section: Int) throws -> UIView? {
        let sectionModel = sections[section]

        guard let headerComponent = sectionModel.header else {
            return nil
        }

        let reuseIdentifier = try reuseIdentifier(for: headerComponent)
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)

        guard let header = header as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: reuseIdentifier)
        }

        headerComponent.prepare()
        header.setRenderer(self)
        header.configure(with: headerComponent)
        tableView.setHeight(headerSection: section, view: header)
        return header
    }

    func footerView(for tableView: UITableView, inSection section: Int) throws -> UIView? {
        let sectionModel = sections[section]

        guard let footerComponent = sectionModel.footer else {
            return nil
        }

        let reuseIdentifier = try reuseIdentifier(for: footerComponent)

        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
        guard let footer = footer as? UITableViewHeaderFooterView & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: reuseIdentifier)
        }

        footerComponent.prepare()
        footer.setRenderer(self)
        footer.configure(with: footerComponent)
        return footer
    }

    func cellView(for tableView: UITableView, at indexPath: IndexPath) throws -> UITableViewCell? {
        guard let cellModel = sections[indexPath.section].rows?[indexPath.row] else {
            throw BlocksError.invalidModelClass
        }

        let reuseIdentifier = try reuseIdentifier(for: cellModel)

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = cell as? UITableViewCell & ComponentViewConfigurable else {
            throw BlocksError.invalidViewClass(reuseIdentifier: reuseIdentifier)
        }

        cellModel.prepare()
        cell.setRenderer(self)
        cell.configure(with: cellModel)
        return cell
    }
}

// MARK: - UITableView Delegate

extension TableViewRenderer {

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

extension TableViewRenderer: UITableViewDragDelegate, UITableViewDropDelegate {
    public func tableView(_ tableView: UITableView,
                          itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = sections[indexPath.section].rows?[indexPath.row]
                as? (any Hashable) else {
            return []
        }

        let itemProvider = NSItemProvider(object: String(item.hashValue) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    public func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let cell = tableView.cellForRow(at: indexPath)
        let previewParameters = UIDragPreviewParameters()
        var frame = cell!.contentView.frame

        frame.origin.x += 20
        frame.origin.y += 2
        frame.size.width -= 40
        frame.size.height -= 4

        let path = UIBezierPath(roundedRect: frame,
                                cornerRadius: 5)
        previewParameters.visiblePath = path
        return previewParameters
    }

    public func tableView(_ tableView: UITableView,
                          performDropWith coordinator: UITableViewDropCoordinator) {
        for item in coordinator.items where item.sourceIndexPath != nil {
            let destinationIndexPath: IndexPath
            if let indexPath = coordinator.destinationIndexPath {
                destinationIndexPath = indexPath
            } else {
                // Default to the last section, last row
                let section = tableView.numberOfSections - 1
                let row = tableView.numberOfRows(inSection: section)
                destinationIndexPath = IndexPath(row: row, section: section)
            }


            var sourceIndexPath = item.sourceIndexPath!
            var sourceItem = sections[sourceIndexPath.section].rows![sourceIndexPath.row]
            var newSections = sections

            newSections[sourceIndexPath.section].rows?.remove(at: sourceIndexPath.row)
            updateSections(newSections, animation: .automatic)

            var destinationRows = newSections[destinationIndexPath.section].rows ?? []
            destinationRows.insert(sourceItem, at: destinationIndexPath.row)
            newSections[destinationIndexPath.section].rows = destinationRows

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.006) { [weak self] in
                self?.updateSections(newSections, animation: .fade)
            }
        }

       /* coordinator.session.loadObjects(ofClass: NSString.self) { [weak self] items in
            guard let self, let items = items as? [String] else { return }

            var indexPaths = [IndexPath]()
            var allRows = self
                .sections
                .compactMap { $0.rows ?? [] }
                .flatMap { $0 }
                .reduce([String: any Component](), { dict, component in
                    var newDict = dict
                    var hashValue = (component as? AnyHashable)?.hashValue ?? -1
                    newDict[String(hashValue)] = component
                    return newDict
                })

            for (index, item) in items.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index,
                                          section: destinationIndexPath.section)

                let sourceItem = allRows[item]!
                let destinationItem = sections[indexPath.section].rows?[indexPath.row]

                removeRows(where: { Box($0) == Box(sourceItem) }, animation: .automatic)
                insertRows([sourceItem], at: indexPath, with: .automatic)
            }
        }*/
    }

    public func tableView(_ tableView: UITableView, 
                          dropSessionDidUpdate session: UIDropSession,
                          withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)

        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }

        if tableView.hasActiveDrag {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return dropProposal
    }

    public func tableView(_ tableView: UITableView,
                          canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
}
