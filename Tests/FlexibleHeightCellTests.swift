// FlexibleHeightCellTests.swift
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
// swiftlint:disable type_body_length

import Foundation
import XCTest

@testable import Blocks

class FlexibleHeightCellTests: XCTestCase {
    enum Constants {
        static let minimumThreshold: CGFloat = 1
        static let maximumThreshold: CGFloat = 1
    }

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
        var renderer = FakeRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
        renderer.register(viewModelType: TestHeaderComponentFlexibleHeight.self,
                          classType: TestHeaderComponentFlexibleHeightView.self)
        return renderer
    }()

    func testThatFlexibleHeightCellsHaveTheCorrectHeight() {
        // Given
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(500)),
            RowSpacer(type: .flexible)
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height - 500
        let cellHeight = round(tableViewHeight/3.0)
        XCTAssertEqual(floor(cell1!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell2!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell4!.frame.size.height), cellHeight)
    }

    func testThatFlexibleHeightHeaderHaveTheCorrectHeight() {
        // Given
        let rows = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(500)),
            RowSpacer(type: .flexible)
        ]

        let section = Section(header: HeaderFooterSpacer(type: .flexible),
                              rows: rows)

        // When
        renderer.updateSections([section], animation: .none)

        var header1: UITableViewHeaderFooterView!
        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            header1 = self.tableView.headerView(forSection: 0)
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height - 500
        let cellHeight = round(tableViewHeight/4.0)
        XCTAssertEqual(floor(header1!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell1!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell2!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell4!.frame.size.height), cellHeight)
    }

    func testThatFlexibleHeightFiiterHaveTheCorrectHeight() {
        // Given
        let rows = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(500)),
            RowSpacer(type: .flexible)
        ]

        let section = Section(footer: HeaderFooterSpacer(type: .flexible),
                              rows: rows)

        // When
        renderer.updateSections([section], animation: .none)

        var footer1: UITableViewHeaderFooterView!
        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            footer1 = self.tableView.footerView(forSection: 0)
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height - 500
        let cellHeight = round(tableViewHeight/4.0)
        XCTAssertEqual(floor(footer1!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell1!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell2!.frame.size.height), cellHeight)
        XCTAssertEqual(floor(cell4!.frame.size.height), cellHeight)
    }

    func testThatFlexibleHeightCellsHaveTheCorrectTotalHeight() {
        // Given
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .flexible),
            RowSpacer(type: .flexible)
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = floor(tableView.frame.height)
        let totalHeight = floor([cell1, cell2, cell3].compactMap({ $0?.frame.height }).reduce(0, { $0 + $1 }))

        XCTAssertEqual(totalHeight, tableViewHeight)
    }

    func testThatFlexibleHeightCellsAndFixedHeightCellsHaveTheCorrectHeight() {
        // Given
        let fixedHeightCellHeight: CGFloat = 121.5
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight))),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight)))
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height
        let cellHeight = floor((tableViewHeight-fixedHeightCellHeight*2)/2.0)
        XCTAssertEqual(floor(cell1!.frame.size.height), floor(cellHeight))
        XCTAssertEqual(floor(cell2!.frame.size.height), floor(fixedHeightCellHeight))
        XCTAssertEqual(floor(cell3!.frame.size.height), floor(cellHeight))
        XCTAssertEqual(floor(cell4!.frame.size.height), floor(fixedHeightCellHeight))
    }

    func testThatFlexibleHeightCellsAndFixedHeightCellsHaveTheCorrectTotalHeight() {
        // Given
        let fixedHeightCellHeight: CGFloat = 121.5
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight))),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight)))
        ]

        // When
        renderer.updateSections([Section(header: TestHeaderComponentFlexibleHeight(),
                                         footer: nil,
                                         rows: models)],
                                animation: .none)

        var header: UITableViewHeaderFooterView!
        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            header = self.tableView.headerView(forSection: 0)
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height
        let totalHeight = round([header, cell1, cell2, cell3, cell4]
            .compactMap({ ($0 as? FlexibleViewHeightProtocol)?.heightConstraint.constant })
                                    .reduce(0, { $0 + $1 }))

        XCTAssertEqual(totalHeight, tableViewHeight)
    }

    func testThatFlexibleHeightHeaderAndFixedHeightCellsHaveTheCorrectTotalHeight() {
        // Given
        let fixedHeightCellHeight: CGFloat = 121.5
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight))),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight)))
        ]

        // When
        renderer.updateSections([Section(header: HeaderFooterSpacer(type: .flexible),
                                         footer: nil,
                                         rows: models)],
                                animation: .none)

        var header: UITableViewHeaderFooterView!
        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            header = self.tableView.headerView(forSection: 0)
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height
        let totalHeight = round([header, cell1, cell2, cell3, cell4]
            .compactMap({ ($0 as? FlexibleViewHeightProtocol)?.heightConstraint.constant })
                                    .reduce(0, { $0 + $1 }))

        XCTAssertEqual(totalHeight, tableViewHeight)
    }

    func testThatFlexibleHeightFooterAndFixedHeightCellsHaveTheCorrectTotalHeight() {
        // Given
        let fixedHeightCellHeight: CGFloat = 121.5
        let models = [
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight))),
            RowSpacer(type: .flexible),
            RowSpacer(type: .fixed(Float(fixedHeightCellHeight)))
        ]

        // When
        renderer.updateSections([Section(header: nil,
                                         footer: HeaderFooterSpacer(type: .flexible),
                                         rows: models)],
                                animation: .none)

        var footer: UITableViewHeaderFooterView!
        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            footer = self.tableView.footerView(forSection: 0)
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RowSpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RowSpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RowSpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RowSpacerCell
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        let tableViewHeight = tableView.frame.height
        let totalHeight = round([footer, cell1, cell2, cell3, cell4]
            .compactMap({ ($0 as? FlexibleViewHeightProtocol)?.heightConstraint.constant })
                                    .reduce(0, { $0 + $1 }))

        XCTAssertEqual(totalHeight, tableViewHeight)
    }
}

// swiftlint:enable type_body_length
