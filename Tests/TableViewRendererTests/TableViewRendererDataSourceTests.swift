// TableViewRendererDataSourceTests.swift
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
// swiftlint:disable file_length type_body_length

import XCTest

@testable import Blocks

class TableViewRendererDataSourceTests: XCTestCase {
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
        TableViewRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
    }()

    // MARK: - Generic

    func testIfRendererUsesTheCorrectTableView() {
        // When
        let tableView = renderer.tableView

        // Then
        XCTAssertEqual(tableView, renderer.tableView)
    }

    // MARK: - Number of Rows/Sections

    func testNumberOfRowsInSection() {
        // Given
        let components = [TestComponentViewModel(),
                          TestComponentViewModel(),
                          TestComponentViewModel()].asBlocks

        // When
        renderer.setRows(components)

        // Then
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), components.count)
    }

    func testNumberOfSections() {
        // Given
        let section1 = Section(id: "section1",
                               items: [TestComponentViewModel(),
                                       TestComponentViewModel(),
                                       TestComponentViewModel()].asBlocks)
        let section2 = Section(id: "section2",
                               items: [TestComponentViewModel(),
                                       TestComponentViewModel(),
                                       TestComponentViewModel()].asBlocks)
        let sections = [section1, section2]

        // When
        renderer.setSections(sections, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, sections.count)
    }

    // MARK: - Header

    func testRendererViewForHeaderInSection() {
        // Given
        let section = Section(id: "section", header: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            let header = try renderer.headerView(for: tableView, inSection: 0)
            XCTAssert(header is TestHeaderFooterView)
        } catch {
            XCTAssert(false)
        }
    }

    func testTableViewHeaderViewForSection() {
        // Given
        let section = Section(id: "section", header: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)
        let header = tableView.headerView(forSection: 0)

        // Then
        XCTAssert(header is TestHeaderFooterView)
    }

    func testRendererInvalidModelForHeaderViewInSection() {
        // Given
        let section = Section(id: "section", header: nil)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            let header = try renderer.headerView(for: tableView, inSection: 0)
            XCTAssertNil(header)
        } catch let error {
            if case .invalidModelClass = error.as(BlocksError.self) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    func testTableViewInvalidModelViewForSection() {
        // Given
        let section = Section(id: "section", header: nil)

        // When
        renderer.setSections([section], animation: .none)
        let header = tableView.headerView(forSection: 0)

        // Then
        XCTAssertNil(header)
    }

    // MARK: - Footer

    func testRendererViewForFooterInSection() {
        // Given
        let section = Section(id: "section", footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            let footer = try renderer.footerView(for: tableView, inSection: 0)
            XCTAssert(footer is TestHeaderFooterView)
        } catch {
            XCTAssert(false)
        }
    }

    func testTableViewFooterForSection() {
        // Given
        let section = Section(id: "section", footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)
        let footer = tableView.footerView(forSection: 0)

        // Then
        XCTAssert(footer is TestHeaderFooterView)
    }

    func testRendererInvalidModelForFooterInSection() {
        // Given
        let section = Section(id: "section", footer: nil)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            let footer = try renderer.footerView(for: tableView, inSection: 0)
            XCTAssert(footer is TestHeaderFooterView)
        } catch {
            if case .invalidModelClass = error.as(BlocksError.self) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    func testTableViewInvalidModelForFooterInSection() {
        // Given
        let section = Section(id: "section", footer: nil)

        // When
        renderer.setSections([section], animation: .none)
        let footer = tableView.footerView(forSection: 0)

        // Then
        XCTAssertNil(footer)
    }

    // MARK: - Cell

    func testRendererClassCellForRowAt() {
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

    func testTableViewClassCellForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(cell is TestComponentCell)
    }

    func testRendererNibCellForRowAt() {
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

    func testTableViewNibCellForRowAt() {
        // Given
        let row = TestNibComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        let cell = tableView.cellForRow(
            at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell?.testLabel)
    }

    func testRendererCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView().asBlock

        // When
        renderer.sections = [Section(id: "section", items: [row])]
        tableView.register(TestComponentInvalidCell.self, forCellReuseIdentifier: "TestComponentInvalidCell")

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView,
                                           at: IndexPath(row: 0, section: 0))
            XCTAssert(false)
        } catch let error {
            if case .invalidViewClass = error.as(BlocksError.self) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    func testTableViewCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView().asBlock

        // When
        renderer.sections = [Section(id: "section", items: [row])]
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(cell == nil)
    }

    func testRendererCallbeforeReuse() {
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

    func testTableViewCallBeforeReuse() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentViewModel.beforeReuseCalled)
    }

    func testRendererCellSetTableView() {
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

    func testTableViewCallSetTableView() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssert(TestComponentCell.tableView == renderer.tableView)
    }

    func testRendererCellForRowCallConfigure() {
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

    func testTableViewCellForRowCallConfigure() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentCell.configureCalled)
    }

    func testRendererHeightForRowAt() {
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

    func testTableViewHeightForRowAt() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])
        let cell = self.renderer.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let size = cell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        // Then
        XCTAssert(Int(size.height) == 152)
    }

    func testRendererHeightForHeaderInSection() {
        // Given
        let section = [Section(id: "section", header: TestHeaderFooterComponentViewModel().asBlock)]

        // When
        renderer.setSections(section,
                             animation: .none)

        // Then
        do {
            let header = try self.renderer.headerView(for: tableView,
                                                      inSection: 0)
            let size = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

            XCTAssert(Int(size.height) == 152)
        } catch {
            XCTAssert(false)
        }
    }

    func testTableHeightForHeaderInSection() {
        // Given
        let section = [Section(id: "section", header: TestHeaderFooterComponentViewModel().asBlock)]

        // When
        renderer.setSections(section,
                             animation: .none)

        // Then
        let header = renderer.tableView(tableView, viewForHeaderInSection: 0)
        let size = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    func testRendererHeightForFooterInSection() {
        // Given
        let section = Section(id: "section", footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        do {
            let footer = try self.renderer.footerView(for: tableView,
                                                      inSection: 0)
            let size = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

            XCTAssert(Int(size.height) == 152)
        } catch {
            XCTAssert(false)
        }
    }

    func testTableViewHeightForFooterInSection() {
        // Given
        let section = Section(id: "section", footer: TestHeaderFooterComponentViewModel().asBlock)

        // When
        renderer.setSections([section], animation: .none)

        // Then
        let footer = self.renderer.tableView.footerView(forSection: 0)
        let size = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    // MARK: - Estimated Heights

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

    func testEstimatedHeightForHeaderInSection() {
        // Given
        let row = TestComponentViewModel().asBlock

        // When
        renderer.setRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
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
}
