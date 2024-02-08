// TableViewRendererProtocol.swift
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

import UIKit.UITableView
import SwiftUI

/// Protocol for UITableView implementation
public protocol TableViewRendererProtocol: UITableViewDataSource, UITableViewDelegate {
    /// The associated UITableView.
    var tableView: UITableView { get }
    /// The cell view models of the UITableView.
    var sections: [Section] { get }

    /// Calculates the estimated height for a row in the table view.
    ///
    /// Use this closure to provide a quick estimate of the height of each row in the table view, improving
    /// the performance of scroll and layout calculations, especially for tables with a large number of items.
    /// - Parameter component: An instance of any `Component` conforming type representing the data model for the row.
    /// - Returns: The estimated height for the row as a `CGFloat`.
    var estimatedHeightForRowComponent: ((any Component) -> CGFloat)? { get set }

    /// Calculates the estimated height for a header in the table view.
    ///
    /// Similar to `estimatedHeightForRowComponent`, this closure provides an 
    /// estimate for the height of section headers,
    /// aiding in the efficient calculation of layout during scrolling.
    /// - Parameter component: An instance of any `Component` conforming type 
    /// representing the data model for the header.
    /// - Returns: The estimated height for the header as a `CGFloat`.
    var estimatedHeightForHeaderComponent: ((any Component) -> CGFloat)? { get set }

    /// Calculates the estimated height for a footer in the table view.
    ///
    /// This closure functions like the ones for row and header components, 
    /// offering a way to estimate the height of section footers.
    /// Providing accurate estimates here can help optimize scrolling and layout computations.
    /// - Parameter component: An instance of any `Component` conforming type 
    /// representing the data model for the footer.
    /// - Returns: The estimated height for the footer as a `CGFloat`.
    var estimatedHeightForFooterComponent: ((any Component) -> CGFloat)? { get set }

    /// Updates the sections on the associated UITableView.
    /// Each section consists of header, footer and items.
    ///
    /// - Parameters:
    ///     - newSections: The new sections of the renderer.
    ///     - animation: The table view animation when instert/update/delete actions are needed.
    func updateSections(_ sections: [Section],
                        animation: UITableView.RowAnimation) throws

    /// Inserts a single section at the specified index.
    /// - Parameters:
    ///   - section: The section to be inserted.
    ///   - index: The index at which the section should be inserted.
    ///   - animation: The animation type to use when inserting the section.
    func insertSection(_ section: Section,
                       at index: Int,
                       with animation: UITableView.RowAnimation)

    /// Inserts multiple sections starting from the specified index.
    /// - Parameters:
    ///   - sections: The array of sections to be inserted.
    ///   - startIndex: The starting index for the insertion of the new sections.
    ///   - animation: The animation type to use when inserting the sections.
    func insertSections(_ sections: [Section],
                        at startIndex: Int,
                        with animation: UITableView.RowAnimation)

    /// Appends a single section at the end.
    /// - Parameters:
    ///   - section: The section to be appended.
    ///   - animation: The animation type to use when appending the section.
    func appendSection(_ section: Section,
                       with animation: UITableView.RowAnimation)

    /// Appends multiple sections at the end.
    /// - Parameters:
    ///   - sections: The array of sections to be appended.
    ///   - animation: The animation type to use when appending the sections.
    func appendSections(_ sections: [Section],
                        with animation: UITableView.RowAnimation)

    /// Removes a single section by its index.
    /// - Parameters:
    ///   - index: The index of the section to be removed.
    ///   - animation: The animation type to use when removing the section.
    func removeSection(at index: Int, with animation: UITableView.RowAnimation)

    /// Removes sections that satisfy the given predicate.
    /// - Parameters:
    ///   - shouldBeRemoved: A closure that takes a Section as
    ///    its argument and returns a Boolean value indicating whether the section should be removed.
    ///   - animation: The animation type to use when removing the sections.
    func removeSections(where shouldBeRemoved: (Section) -> Bool,
                        with animation: UITableView.RowAnimation)

    /// Creates a default Section and updates its items to the given rows.
    /// It also updates only the required to change rows.
    ///
    /// - Parameters:
    ///     - rows: The new sections of the renderer.
    ///     - animation: The table view animation applied when update actions are made.
    func updateRows(_ rows: [any Component],
                    with animation: UITableView.RowAnimation) throws

    /// Appends a row to the given Section Index. If no Section Index is given,
    /// it appends the row to the last Section. It finally applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - newSections: The new sections of the renderer.
    ///     - animation: The table view animation applied when update actions are made.
    func appendRow(_ row: any Component,
                   atSectionIndex index: Int?,
                   with animation: UITableView.RowAnimation) throws

    /// Inserts a row to the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - row: The row which will be inserted at the given index path.
    ///     - indexPath: The index path where the row will be inserted.
    ///     - animation: The table view animation applied when update actions are made.
    func insertRow(_ row: any Component,
                   at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation) throws

    /// Inserts a rows to the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - rows: The rows which will be inserted at the given index path.
    ///     - indexPath: The index path where the row will be inserted.
    ///     - animation: The table view animation applied when update actions are made.
    func insertRows(_ rows: [any Component],
                    at indexPath: IndexPath,
                    with animation: UITableView.RowAnimation) throws

    /// Removes the row from the given IndexPath and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - indexPath: The index path where the row will be removed.
    ///     - animation: The table view animation applied when update actions are made.
    func removeRow(at indexPath: IndexPath,
                   with animation: UITableView.RowAnimation) throws

    /// Removes the rows with the given predicate and also applies the changes using diffable data source.
    ///
    /// - Parameters:
    ///     - predicate: A closure that takes an element as its argument and
    ///     returns a Boolean value that indicates whether the passed element represents a match.
    ///     - animation: The table view animation applied when update actions are made.
    func removeRows(where predicate: (any Component) -> Bool, animation: UITableView.RowAnimation) throws

    /// Default initializer.
    ///
    /// - Parameters:
    ///     - tableView: The table view that is used as a container of rendering Components
    ///     - bundle: The bundle of the xibs that are used by the Components. If this value
    ///               is nil, the default bundle is used.
    init(tableView: UITableView, bundle: Bundle?)

    /// Registers a nib file with the table view renderer for a given view model type.
    ///
    /// - Parameters:
    ///   - viewModelType: The component view model type that the nib file is associated with.
    ///                    This type must conform to the `Component` protocol.
    ///   - nibName: The name of the nib file (without the .xib extension) to register.
    ///
    /// Note: The nib file should contain a view that is designed to 
    /// display the data from the specified view model type.
    func register(viewModelType: any Component.Type, nibName: String)

    /// Registers a class with the table view renderer for a given view model type.
    ///
    /// - Parameters:
    ///   - viewModelType: The component view model type that the class is associated with.
    ///                    This type must conform to the `Component` protocol.
    ///   - classType: The class of the view to register. This class should be a subclass of `UIView` and designed
    ///                to display the data from the specified view model type.
    func register(viewModelType: any Component.Type, classType: AnyClass)

    /// Registers a SwiftUI view type with a view model type.
    ///
    /// Associates a view model type, conforming to `Component`, with a SwiftUI view conforming to
    /// `ComponentSwiftUIViewConfigurable`. This enables dynamic view instantiation based on view model type,
    /// supporting a decoupled architecture where the view layer is dictated by view models.
    ///
    /// - Parameters:
    ///   - viewModelType: The view model type to associate with a SwiftUI view.
    ///   - viewType: The SwiftUI view type, conforming to `ComponentSwiftUIViewConfigurable`, to register.
    ///
    /// This method simplifies connecting view models to their views, enhancing maintainability and flexibility.
    /// Ensure the SwiftUI view provides configuration or instantiation logic as 
    /// required by `ComponentSwiftUIViewConfigurable`.
    func register<View: ComponentSwiftUIViewConfigurable>(viewModelType: any Component.Type, viewType: View.Type)
}
