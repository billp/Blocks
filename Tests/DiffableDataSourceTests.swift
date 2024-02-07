// DiffableDataSourceTests.swift
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
//
// swiftlint:disable type_body_length

import XCTest
@testable import Blocks

class DiffableDataSourceTests: XCTestCase {
    lazy var sampleViewController: SampleViewController = {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let viewController = SampleViewController()
        viewController.view.bounds = window.bounds
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return viewController
    }()

    var tableView: UITableView {
        sampleViewController.tableView
    }

    lazy var renderer: FakeRenderer = {
        FakeRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
    }()

    override func setUp() {
        super.setUp()

        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]

        // When
        renderer.updateRows(models.asBlocks)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, models[1].title)
    }

    override func tearDown() {
        super.tearDown()

        // When
        renderer.updateRows([].asBlocks)

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
    }

    func testOnInsertAfterRow1Action() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.insertRow(newModel.asBlock, at: IndexPath(row: 1, section: 0), with: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 1)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, newModel.title)
        XCTAssertEqual(cell3?.testLabel.text, models[1].title)
        XCTAssertEqual(renderer.cellForRowCallCount, 1)
    }

    func testOnInsertAfterRow2Action() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.insertRow(newModel.asBlock, at: IndexPath(row: 2, section: 0), with: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 1)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, models[1].title)
        XCTAssertEqual(cell3?.testLabel.text, newModel.title)
        XCTAssertEqual(renderer.cellForRowCallCount, 1)
    }

    func testOnInsertMultipleRowsAtTheBeginningAction() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")
        let newModel2 = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello4")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2].asBlocks, at: IndexPath(row: 0, section: 0), with: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell
        let cell4 = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertNotNil(cell4)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 2)
        XCTAssertEqual(cell1?.testLabel.text, newModel.title)
        XCTAssertEqual(cell2?.testLabel.text, newModel2.title)
        XCTAssertEqual(cell3?.testLabel.text, models[0].title)
        XCTAssertEqual(cell4?.testLabel.text, models[1].title)
        XCTAssertEqual(renderer.cellForRowCallCount, 2)
    }

    func testOnInsertMultipleRowsInTheMiddleAction() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")
        let newModel2 = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello4")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2].asBlocks, at: IndexPath(row: 1, section: 0), with: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell
        let cell4 = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertNotNil(cell4)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 2)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, newModel.title)
        XCTAssertEqual(cell3?.testLabel.text, newModel2.title)
        XCTAssertEqual(cell4?.testLabel.text, models[1].title)
        XCTAssertEqual(renderer.cellForRowCallCount, 2)
    }

    func testOnInsertMultipleRowsAtTheEndAction() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")
        let newModel2 = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello4")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2].asBlocks, at: IndexPath(row: 2, section: 0), with: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell
        let cell4 = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertNotNil(cell4)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 2)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, models[1].title)
        XCTAssertEqual(cell3?.testLabel.text, newModel.title)
        XCTAssertEqual(cell4?.testLabel.text, newModel2.title)
        XCTAssertEqual(renderer.cellForRowCallCount, 2)
    }

    func testOnAppend() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello3")

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.appendRow(newModel.asBlock)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertNotNil(cell3)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count + 1)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, models[1].title)
        XCTAssertEqual(cell3?.testLabel.text, newModel.title)
        XCTAssertEqual(renderer.cellForRowCallCount, 1)
    }

    func testOnRemoveAtRow0() {
        // Given
        renderer.cellForRowCallCount = 0

        // When
        renderer.removeRow(from: IndexPath(row: 0, section: 0), with: .none)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(cell?.testLabel.text, "Hello2")
    }

    func testOnRemoveAtRow1() {
        // Given
        renderer.cellForRowCallCount = 0

        // When
        renderer.removeRow(from: IndexPath(row: 1, section: 0), with: .none)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(cell?.testLabel.text, "Hello1")
        XCTAssertEqual(renderer.cellForRowCallCount, 0)
    }

    func testOnRemoveAtMultipleRows() {
        // Given
        renderer.cellForRowCallCount = 0

        // When
        renderer.removeRows(where: { _ in true }, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(renderer.cellForRowCallCount, 0)
    }

    func testOnMoveRows() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.updateRows([models[1], models[0]].asBlocks)

        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count)
        XCTAssertEqual(cell1?.testLabel.text, models[1].title)
        XCTAssertEqual(cell2?.testLabel.text, models[0].title)
        XCTAssertEqual(renderer.cellForRowCallCount, 0)
    }

    func testOnRemoveWhere() {
        // Given
        let models: [AnyHashable] = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test2", title: "Hello2"),
            TestComponentViewModel(componentId: "test3")
        ]

        // When
        renderer.updateRows(models.asBlocks)
        renderer.removeRows(where: { block in
            guard let reuseIdentifier = (block.component as? AnyComponent)?.reuseIdentifier else {
                return false
            }
            return ["TestComponentCell", "test"].contains(reuseIdentifier)
        }, animation: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(cell1?.testLabel.text, "Hello2")
    }

    func testOnNoChange() {
        // Given
        let models = [
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello1"),
            TestNibComponentViewModel(reuseIdentifier: "test", title: "Hello2")
        ]

        // When
        renderer.updateRows(models.asBlocks)
        renderer.cellForRowCallCount = 0
        renderer.updateRows([models[0], models[1]].asBlocks)

        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell1)
        XCTAssertNotNil(cell2)
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), models.count)
        XCTAssertEqual(cell1?.testLabel.text, models[0].title)
        XCTAssertEqual(cell2?.testLabel.text, models[1].title)
        XCTAssertEqual(renderer.cellForRowCallCount, 0)
    }
}

class FakeRenderer: TableViewRenderer {
    var cellForRowCallCount: Int = 0
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRowCallCount += 1
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

// swiftlint:enable type_body_length
