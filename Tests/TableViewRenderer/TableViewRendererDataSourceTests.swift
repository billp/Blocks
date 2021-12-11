//
//  BlocksTests.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 11/12/21.
//

import XCTest

@testable import Blocks

class BlocksTests: XCTestCase {
    let tableView = UITableView()
    lazy var renderer = TableViewRenderer(tableView: tableView)

    func testNumberOfRowsInSection() {
        // Given
        let components = [TestComponentViewModel(), TestComponentViewModel(), TestComponentViewModel()]

        // When
        renderer.setRows(components)

        // Then
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), components.count)
    }

    func testNumberOfSections() {
        // Given
        let section1 = Section(model: TableViewSection(id: "test", header: nil, footer: nil),
                               elements: [TestComponentViewModel(),
                                          TestComponentViewModel(),
                                          TestComponentViewModel()])
        let section2 = Section(model: TableViewSection(id: "test", header: nil, footer: nil),
                               elements: [TestComponentViewModel(),
                                          TestComponentViewModel(),
                                          TestComponentViewModel()])
        let sections = [section1, section2]

        // When
        renderer.setSections(sections, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, sections.count)
    }
}
