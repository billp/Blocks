//
//  BlockTests.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 15/1/22.
//

import XCTest
@testable import Blocks

class BlockTests: XCTestCase {

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
        return renderer
    }()

    func testBlocksAs() {
        // Given
        let component = TestComponentViewModel().asBlock
        // When
        renderer.setRows([component])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssertNotNil(TestComponentCell.model)
        } catch {
            XCTAssert(false)
        }
    }
}
