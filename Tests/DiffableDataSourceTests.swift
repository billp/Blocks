// DiffableDataSourceTests.swift
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
        let renderer = FakeRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
        renderer.register(viewModelType: TestNibComponentViewModel.self,
                          nibName: String(describing: TestNibComponentViewCell.self))
        renderer.register(viewModelType: TestComponentViewModel.self,
                          classType: TestComponentCell.self)

        return renderer
    }()

    override func setUp() {
        super.setUp()

        let models = [
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]

        renderer.updateRows(models)
    }

    override func tearDown() {
        super.tearDown()
        renderer.updateRows([])
    }

    func testOnInsertAfterRow1Action() {
        // Given
        let models = [
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.insertRow(newModel, at: IndexPath(row: 1, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.insertRow(newModel, at: IndexPath(row: 2, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")
        let newModel2 = TestNibComponentViewModel(title: "Hello4")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2], at: IndexPath(row: 0, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")
        let newModel2 = TestNibComponentViewModel(title: "Hello4")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2], at: IndexPath(row: 1, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")
        let newModel2 = TestNibComponentViewModel(title: "Hello4")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.insertRows([newModel, newModel2], at: IndexPath(row: 2, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]
        let newModel = TestNibComponentViewModel(title: "Hello3")

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.appendRow(newModel)
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
        renderer.removeRow(at: IndexPath(row: 0, section: 0), with: .none)
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
        renderer.removeRow(at: IndexPath(row: 1, section: 0), with: .none)
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
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.updateRows([models[1], models[0]])

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
        let models: [any Component] = [
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2"),
            TestComponentViewModel(text: "test3")
        ]

        // When
        renderer.updateRows(models)
        renderer.removeRows(where: { block in
            let type = String(describing: type(of: block))
            return ["TestNibComponentViewModel"].contains(type)
        }, animation: .none)
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TestComponentCell

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(cell1?.label.text, "test3")
    }

    func testOnNoChange() {
        // Given
        let models = [
            TestNibComponentViewModel(title: "Hello1"),
            TestNibComponentViewModel(title: "Hello2")
        ]

        // When
        renderer.updateRows(models)
        renderer.cellForRowCallCount = 0
        renderer.updateRows([models[0], models[1]])

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
