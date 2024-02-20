// ExtensionTests.swift
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

import XCTest
@testable import Blocks

class ExtensionTests: XCTestCase {
    lazy var sampleViewController: SampleViewController = {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let viewController = SampleViewController()

        viewController.view.bounds = CGRect(x: 0, y: 0, width: 375, height: 667)
        viewController.tableView.translatesAutoresizingMaskIntoConstraints = false

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        return viewController
    }()

    var tableView: UITableView {
        sampleViewController.tableView
    }

    lazy var renderer: TableViewRenderer = {
        let renderer = TableViewRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
        renderer.register(viewModelType: TestComponentViewModel.self, classType: TestComponentCell.self)
        return renderer
    }()

    func testAsBlock() {
        // Given
        let component = TestComponentViewModel()
        TestComponentCell.models.removeAll()

        // When
        renderer.updateRows([component])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssertEqual(TestComponentCell
                            .models
                            .compactMap({ return String(describing: $0) }).count, 1)
        } catch {
            XCTAssert(false)
        }
    }

    func testAsBlocks() {
        // Given
        let blocks = [TestComponentViewModel(), TestComponentViewModel()]
        TestComponentCell.models.removeAll()

        // When
        renderer.updateRows(blocks)

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssertEqual(TestComponentCell
                            .models
                            .compactMap({ return String(describing: $0) }).count, 2)
        } catch {
            XCTAssert(false)
        }
    }
}
