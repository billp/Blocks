// TableViewRenderer+ViewHelpers.swift
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
import SwiftUI

extension TableViewRenderer {
    /// Retrieves the registered nib name for a given view model instance.
    ///
    /// - Parameter component: The instance of the view model for which to retrieve the registered nib name.
    /// - Returns: The nib name registered for the type of the given view model instance.
    ///  This allows the caller to know whether a specific view model
    ///  instance's type has a nib file associated with it for UI rendering purposes.
    func nibName(for component: any Component) throws -> String {
        let typeId = ObjectIdentifier(type(of: component))

        if let nibName = nibRegistrations[typeId] {
            return nibName
        }

        throw BlocksError.viewModelNotRegistered
    }

    /// Retrieves the registered class for a given view model instance.
    ///
    /// - Parameter component: The instance of the view model for which to retrieve the registered class.
    /// - Returns: The class registered for the type of the given view model instance, if available; otherwise, `nil`.
    /// This allows the caller to know whether a specific view model
    /// instance's type has a class associated with it for UI rendering purposes.
    func viewClass(for component: any Component) throws -> AnyClass {
        let typeId = ObjectIdentifier(type(of: component))

        if let classType = classRegistrations[typeId] {
            return classType
        }

        throw BlocksError.viewModelNotRegistered
    }

    /// Retrieves a SwiftUI view factory for a given view model instance.
    ///
    /// - Parameter component: The instance of the view model for which to retrieve the SwiftUI view factory.
    /// - Returns: A closure that produces the SwiftUI view registered for the type of the given view model instance.
    /// This allows the caller to dynamically instantiate the associated SwiftUI view for UI rendering purposes.
    /// - Throws: `BlocksError` if no view is registered for the view model type.
    func swiftUIView<ComponentType: Component>(for component: ComponentType) throws -> any View {
        let typeId = ObjectIdentifier(type(of: component))

        guard let view = swiftUIRegistrations[typeId] else {
            throw BlocksError.viewModelNotRegistered
        }

        return view.init(viewModel: component)
    }

    /// Attempts to retrieve a representation (nib name or class name as a string) for a given view model instance.
    ///
    /// - Parameter component: The instance of the view model for which to retrieve the representation.
    /// - Returns: An optional string representing either the nib name or the class name,
    /// or `nil` if neither registration exists.
    func reuseIdentifier(for component: any Component) throws -> String {
        // Attempt to retrieve the nib name
        if let nibName = try? nibName(for: component) {
            return nibName
        }

        // Attempt to retrieve the class name as a string
        if let viewClass = try? viewClass(for: component) {
            return String(describing: viewClass)
        }

        // Attempt to retrieve the SwiftUI view name as a string
        if let viewName = try? swiftUIView(for: component) {
            return String(describing: type(of: viewName))
        }

        throw BlocksError.viewModelNotRegistered
    }

    /// Checks if a Swift UI view exists for the specified component.
    ///
    /// This function attempts to retrieve a SwiftUI view for a given component 
    /// by calling the `swiftUIView(for:)` method. It returns true if the method
    /// successfully returns a non-nil view without throwing an error. Otherwise, it returns false.
    ///
    /// - Parameter component: The component for which to retrieve the SwiftUI view.
    /// - Returns: A Boolean value indicating whether a non-nil SwiftUI view exists for the specified component.
    func hasSwiftUIView(for component: any Component) -> Bool {
        if (try? self.swiftUIView(for: component)) != nil {
            return true
        } else {
            return false
        }
    }

    /// Retrieves or creates a header view for a given table view section.
    /// - Parameters:
    ///   - tableView: The table view requesting the header.
    ///   - section: The index of the section requesting the header.
    /// - Returns: A configured header view or `nil` if the section does not have a header.
    /// - Throws: `BlocksError.invalidViewClass` if the dequeued view does not conform to `ComponentViewConfigurable`.
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

    /// Retrieves or creates a footer view for a given table view section.
    /// - Parameters:
    ///   - tableView: The table view requesting the footer.
    ///   - section: The index of the section requesting the footer.
    /// - Returns: A configured footer view or `nil` if the section does not have a footer.
    /// - Throws: `BlocksError.invalidViewClass` if the dequeued view does not conform to `ComponentViewConfigurable`.
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

    /// Retrieves or creates a cell for a given table view indexPath.
    /// - Parameters:
    ///   - tableView: The table view requesting the cell.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A configured cell.
    /// - Throws: `BlocksError.invalidModelClass` if the model for the cell is invalid.
    ///           `BlocksError.invalidViewClass` if the dequeued cell does not conform to `ComponentViewConfigurable`.
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
