//
//  FlexibleHeightCellTests.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 12/4/22.
//

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
            Spacer(type: .flexible),
            Spacer(type: .flexible),
            Spacer(type: .fixed(500)),
            Spacer(type: .flexible)
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SpacerCell
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

    func testThatFlexibleHeightCellsHaveTheCorrectTotalHeight() {
        // Given
        let models = [
            Spacer(type: .flexible),
            Spacer(type: .flexible),
            Spacer(type: .flexible)
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SpacerCell
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
            Spacer(type: .flexible),
            Spacer(type: .fixed(Float(fixedHeightCellHeight))),
            Spacer(type: .flexible),
            Spacer(type: .fixed(Float(fixedHeightCellHeight)))
        ]

        // When
        renderer.updateRows(models)

        var cell1: UITableViewCell!
        var cell2: UITableViewCell!
        var cell3: UITableViewCell!
        var cell4: UITableViewCell!

        let expectation = self.expectation(description: "Update main queue.")

        DispatchQueue.main.async {
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SpacerCell
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
            Spacer(type: .flexible),
            Spacer(type: .fixed(Float(fixedHeightCellHeight))),
            Spacer(type: .flexible),
            Spacer(type: .fixed(Float(fixedHeightCellHeight)))
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
            cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SpacerCell
            cell2 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SpacerCell
            cell3 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SpacerCell
            cell4 = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SpacerCell
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
}
