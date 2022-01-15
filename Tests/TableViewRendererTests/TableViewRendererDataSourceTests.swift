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

    lazy var renderer: TableViewRenderer = {
        let renderer = TableViewRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
        renderer.delegate = self
        return renderer
    }()

    // MARK: - Number of Rows/Sections

    func testNumberOfRowsInSection() {
        // Given
        let components = [TestComponentViewModel(), TestComponentViewModel(), TestComponentViewModel()]
                            .map { $0.asBlock }

        // When
        renderer.setRows(components)

        // Then
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), components.count)
    }

    func testNumberOfSections() {
        // Given
        let section1 = Section(items: [TestComponentViewModel(),
                                       TestComponentViewModel(),
                                       TestComponentViewModel()].map({ $0.asBlock }))
        let section2 = Section(items: [TestComponentViewModel(),
                                       TestComponentViewModel(),
                                       TestComponentViewModel()].map({ $0.asBlock }))
        let sections = [section1, section2]

        // When
        renderer.setSections(sections, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, sections.count)
    }

    // MARK: - Header

    func testViewForHeaderInSection() {
        // Given
        let section = Section(header: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        XCTAssert(renderer.tableView(tableView, viewForHeaderInSection: 0) is TestHeaderFooterView)
    }

    // MARK: - Footer

    func testViewForFooterInSection() {
        // Given
        let section = Section(footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        XCTAssert(renderer.tableView(tableView, viewForFooterInSection: 0) is TestHeaderFooterView)
    }

    func testViewForFooterInSectionInvalidModel() {
        // Given
        let section = Section(footer: TestHeaderFooterComponentInvalidModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            _ = try self.renderer.footerView(for: tableView, inSection: 0)
        } catch let error {
            if case .invalidModelClass = (error as? BlocksError) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    // MARK: - Cell

    func testClassCellForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: tableView,
                                                     at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is TestComponentCell)
        } catch {
            XCTAssert(false)
        }
    }

    func testNibCellForRowAt() {
        // Given
        let row = TestNibComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: tableView,
                                                     at: IndexPath(row: 0, section: 0))
                as? TestNibComponentViewCell
            XCTAssertNotNil(cell)
            XCTAssertNotNil(cell?.testLabel)
        } catch {
            XCTAssert(false)
        }
    }

    func testDiffableClassCellForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then

        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssert(cell is TestComponentCell)
    }

    func testDiffableNibCellForRowAt() {
        // Given
        let row = TestNibComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then

        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssert(cell is TestNibComponentViewCell)
    }

    func testCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView().asBlock

        // When
        renderer.sections = [Section(items: [row])]
        tableView.register(TestComponentInvalidCell.self, forCellReuseIdentifier: "TestComponentInvalidCell")

        // Then
        do {
            let cell = try self.renderer.cellView(for: tableView,
                                                  at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is TestComponentCell)
        } catch let error {
            if case .invalidViewClass = (error as? BlocksError) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    func testCellForRowAtInvalidViewCallbeforeReuse() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentViewModel.beforeReuseCalled)
        } catch {
            XCTAssert(false)
        }
    }

    func testCellForRowAtInvalidViewCallSetTableView() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentCell.tableView == renderer.tableView)
        } catch {
            XCTAssert(false)
        }
    }

    func testCellForRowAtInvalidViewCallConfigure() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentCell.configureCalled)
        } catch {
            XCTAssert(false)
        }
    }

    func testHeightForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: tableView,
                                                     at: IndexPath(row: 0, section: 0))
            let size = cell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

            XCTAssert(Int(size.height) == 152)
        } catch {
            XCTAssert(false)
        }
    }

    func testEstimatedHeightForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView,
                                                 estimatedHeightForRowAt: IndexPath(row: 0, section: 0))

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testHeightForFooterInSection() {
        // Given
        let section = Section(footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        let footer = self.renderer.tableView(tableView, viewForFooterInSection: 0)
        let size = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    func testEstimatedHeightForFooterInSection() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testHeightForHeaderInSection() {
        // Given
        let section = [Section(header: TestHeaderFooterComponentViewModel().asBlock)]

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
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testDidSelectRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        renderer.tableView.delegate?.tableView?(tableView,
                                                didSelectRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(BlocksTests.didSelectCalled)
    }

    func testComponentViewModelSelectable() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        renderer.tableView.delegate?.tableView?(tableView,
                                                didSelectRowAt: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentViewModel.isSelected)
    }
}

extension BlocksTests: TableViewRendererDelegate {
    func didSelectRow(_ viewModel: Block,
                      tableView: UITableView,
                      indexPath: IndexPath) {
        BlocksTests.didSelectCalled = true
    }
}
