// TableViewRenderer.swift
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

    /// Closure to estimate row height. Accepts `Component`, returns estimated `CGFloat`.
    public var estimatedHeightForRowComponent: ((any Component) -> CGFloat)?

    /// Closure to estimate header height. Accepts `Component`, returns estimated `CGFloat`.
    public var estimatedHeightForHeaderComponent: ((any Component) -> CGFloat)?

    /// Closure to estimate footer height. Accepts `Component`, returns estimated `CGFloat`.
    public var estimatedHeightForFooterComponent: ((any Component) -> CGFloat)?

    /// An optional property that stores the index path of the item being dragged.
    /// This value is used to track the original position of an item during a drag and drop operation.
    var dragSourceIndexPath: IndexPath?

    /// A Boolean property indicating whether drag interaction is enabled for a component.
    /// Setting this property calls `setDragInteractionEnabled(_:)` with the new value.

    public var dragEnabled: Bool = false {
        didSet { setDragInteractionEnabled(dragEnabled) }
    }

    /// A closure called when a drag operation starts.
    ///
    /// This property serves as a notification hook for when a drag operation is initiated, allowing
    /// for custom actions or state updates at the start of dragging.
    public var dragStarted: (() -> Void)?

    /// A closure that determines if an item at a given `IndexPath` can be dragged.
    /// - Parameter
    ///     - sourceIndexPath: The index path of the item to be evaluated for drag capability.
    ///     - component: The component that will be dragd.
    /// - Returns: A Boolean value indicating whether the item can be dragged.
    public var canDrag: (_ sourceIndexPath: IndexPath, _ component: any Component) -> Bool = { _, _ in true }

    /// A closure that determines if an item can be dropped at a specified location.
    /// - Parameters:
    ///   - sourceIndexPath: The source index path of the item being dragged.
    ///   - destinationIndexPath: The destination index path where the item might be dropped.
    /// - Returns: A Boolean value indicating whether the item can be dropped at the destination index path.

    public var canDrop: (_ sourceIndexPath: IndexPath,
                           _ destinationIndexPath: IndexPath) -> Bool = { _, _ in true }
    /// A closure that is called when a drop action has been completed.
    /// - Parameters:
    ///   - sourceIndexPath: The source index path from which the item was dragged.
    ///   - destinationIndexPath: The destination index path where the item was dropped.
    public var dropCompleted: ((_ sourceIndexPath: IndexPath,
                                _ destinationIndexPath: IndexPath) -> Void)?

    /// A closure for customizing the drag preview appearance for a draggable component in a table view.
    ///
    /// This property enables customization of the drag preview for a specific component being dragged,
    /// allowing adjustments to the preview's frame and the application of a corner radius,
    /// thus enhancing visual feedback during drag operations.
    ///
    /// - Parameter component: The component associated with the table view row being dragged.
    ///                        It is used to determine the custom drag preview properties.
    /// - Returns: An optional `DragViewMaskProperties` object with insets and corner radius for the drag preview.
    ///            Returns nil to apply default drag preview parameters.
    public var customizeDragPreviewForComponent: ((_ component: any Component) -> DragViewMaskProperties)?

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
    /// - Parameters:
    ///   - newSections: The new sections that are used to find differences and apply changes.
    ///   This array of `Section` objects represents the updated state of the table view sections.
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

    /// Configures the table view for drag and drop interactions based on the specified enabled state.
    /// - Parameter enabled: A Boolean value that determines whether drag and drop interactions are enabled.
    /// When `true`, the renderer is configured to allow drag and drop operations.
    /// When `false`, drag and drop interactions are disabled.
    private func setDragInteractionEnabled(_ enabled: Bool) {
        tableView.dragInteractionEnabled = enabled
        tableView.dropDelegate = enabled ? self : nil
        tableView.dragDelegate = enabled ? self : nil
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
