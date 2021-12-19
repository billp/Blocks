//
//  BlocksTests.swift
//  BlocksTests
//
//  Created by Vassilis Panagiotopoulos on 11/12/21.
//

import XCTest

@testable import Blocks

class BlocksTests: XCTestCase {
    static var didSelectCalled = false

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()

    lazy var renderer: TableViewRenderer = {
        let renderer = TableViewRenderer(tableView: tableView)
        renderer.delegate = self
        return renderer
    }()

    // MARK: - Number of Rows/Sections

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
        let section1 = Section(model: TableViewSection(sectionId: "test", header: nil, footer: nil),
                               elements: [TestComponentViewModel(),
                                          TestComponentViewModel(),
                                          TestComponentViewModel()])
        let section2 = Section(model: TableViewSection(sectionId: "test2", header: nil, footer: nil),
                               elements: [TestComponentViewModel(),
                                          TestComponentViewModel(),
                                          TestComponentViewModel()])
        let sections = [section1, section2]

        // When
        renderer.setSections(sections, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, sections.count)
    }

    // MARK: - Header

    func testViewForHeaderInSection() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: TestHeaderFooterComponentViewModel(),
                                                      footer: nil),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        XCTAssert(renderer.tableView(self.tableView, viewForHeaderInSection: 0) is TestHeaderFooterView)
    }

    func testViewForHeaderInSectionInvalidModel() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: TestHeaderFooterComponentInvalidModel(),
                                                      footer: nil),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            _ = try self.renderer.headerView(for: self.tableView, inSection: 0)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidModelClass)
        }
    }

    func testViewForHeaderInSectionInvalidView() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: TestHeaderFooterComponentInvalidView(),
                                                      footer: nil),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            _ = try self.renderer.headerView(for: self.tableView, inSection: 0)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidViewClass)
        }
    }

    // MARK: - Footer

    func testViewForFooterInSection() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: nil,
                                                      footer: TestHeaderFooterComponentViewModel()),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        XCTAssert(renderer.tableView(self.tableView, viewForFooterInSection: 0) is TestHeaderFooterView)
    }

    func testViewForFooterInSectionInvalidModel() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: nil,
                                                      footer: TestHeaderFooterComponentInvalidModel()),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            _ = try self.renderer.footerView(for: self.tableView, inSection: 0)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidModelClass)
        }
    }

    func testViewForFooterInSectionInvalidView() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: nil,
                                                      footer: TestHeaderFooterComponentInvalidView()),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            _ = try self.renderer.footerView(for: self.tableView, inSection: 0)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidViewClass)
        }
    }

    // MARK: - Cell

    func testCellForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is TestComponentCell)
        } catch {
            XCTAssert(false)
        }
    }

    func testCellForRowAtInvalidModel() {
        // Given
        let row = TestComponentInvalidModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is TestComponentCell)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidModelClass)
        }
    }

    func testCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView()

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is TestComponentCell)
        } catch let error {
            XCTAssert(error as? BlocksError == BlocksError.invalidViewClass)
        }
    }

    func testCellForRowAtInvalidViewCallbeforeReuse() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentViewModel.beforeReuseCalled)
        } catch {
            XCTAssert(false)
        }
    }

    func testCellForRowAtInvalidViewCallSetTableView() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentCell.tableView == tableView)
        } catch {
            XCTAssert(false)
        }
    }

    func testCellForRowAtInvalidViewCallConfigure() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentCell.configureCalled)
        } catch {
            XCTAssert(false)
        }
    }

    func testHeightForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: self.tableView, at: IndexPath(row: 0, section: 0))
            let size = cell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

            XCTAssert(Int(size.height) == 152)
        } catch {
            XCTAssert(false)
        }
    }

    func testEstimatedHeightForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0))

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testHeightForFooterInSection() {
        // Given
        let section = Section(model: TableViewSection(sectionId: "test",
                                                      header: nil,
                                                      footer: TestHeaderFooterComponentViewModel()),
                              elements: [])

        // When
        renderer.setSections([section], animation: .none)

        // Then
        let footer = self.renderer.tableView(tableView, viewForFooterInSection: 0)
        let size = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    func testEstimatedHeightForFooterInSection() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testHeightForHeaderInSection() {
        // Given
        let section = [Section(model: TableViewSection(sectionId: "a",
                                                       header: TestHeaderFooterComponentViewModel(),
                                                       footer: nil),
                               elements: [])]

        // When
        renderer.setSections(section,
                             animation: .none)

        // Then
        let header = renderer.tableView(tableView, viewForHeaderInSection: 0)
        let size = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    func testEstimatedHeightForHeaderInSection() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testDidSelectRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])
        renderer.tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(BlocksTests.didSelectCalled)
    }

    func testComponentViewModelSelectable() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.setRows([row])
        renderer.tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentViewModel.isSelected)
    }
}

extension BlocksTests: TableViewRendererDelegate {
    func didSelectRow(_ viewModel: ComponentViewModel,
                      tableView: UITableView,
                      indexPath: IndexPath) {
        BlocksTests.didSelectCalled = true
    }
}
