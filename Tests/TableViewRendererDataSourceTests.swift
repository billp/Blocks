// TableViewRendererDataSourceTests.swift
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
// swiftlint:disable file_length type_body_length

import XCTest

@testable import Blocks

class TableViewRendererDataSourceTests: XCTestCase {
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
        renderer.register(viewModelType: TestComponentViewModel.self,
                          classType: TestComponentCell.self)
        renderer.register(viewModelType: TestNibComponentViewModel.self,
                          nibName: String(describing: TestNibComponentViewCell.self))
        renderer.register(viewModelType: TestHeaderFooterComponentViewModel.self,
                          classType: TestHeaderFooterView.self)
        renderer.register(viewModelType: TestViewComponent.self,
                          viewType: TestView.self)

        return renderer
    }()

    // MARK: - Generic

    func testIfRendererUsesTheCorrectTableView() {
        // When
        let tableView = renderer.tableView

        // Then
        XCTAssertEqual(tableView, renderer.tableView)
    }

    func testRegisterNibForReuseIdentifier() {
        // Given
        let models = [TestNibComponentViewModel(),
                      TestNibComponentViewModel()]
        // When
        renderer.updateRows(models)

        // Then
        XCTAssert(renderer.registeredNibNames.contains("TestNibComponentViewCell"))
        XCTAssert(renderer.registeredNibNames.contains("TestNibComponentViewCell"))
        XCTAssertNotNil(tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)))
        XCTAssertNotNil(tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)))
    }

    func testRegisterClassForReuseIdentifier() {
        // Given
        struct TestComponent: Component {
            var viewClass: AnyClass {
                TestComponentCell.self
            }

            var id: UUID = .init()
        }
        class TestComponentCell: UITableViewCell { }
        renderer.register(viewModelType: TestComponent.self, classType: TestComponentCell.self)

        // When
        renderer.updateRows([TestComponent(), TestComponent()])

        // Then
        XCTAssert(renderer.registeredClassNames.contains("TestComponentCell"))
        XCTAssertNotNil(tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)))
    }

    // MARK: - Number of Rows/Sections

    func testNumberOfRowsInSection() {
        // Given
        let components = [TestComponentViewModel(),
                          TestComponentViewModel(),
                          TestComponentViewModel()]

        // When
        renderer.updateRows(components)

        // Then
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), components.count)
    }

    func testNumberOfSections() {
        // Given
        let section1 = Section(rows: [TestComponentViewModel(),
                                      TestComponentViewModel(),
                                      TestComponentViewModel()])
        let section2 = Section(rows: [TestComponentViewModel(),
                                      TestComponentViewModel(),
                                      TestComponentViewModel()])
        let sections = [section1, section2]

        // When
        renderer.updateSections(sections, animation: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, sections.count)
    }

    // MARK: - Header

    func testRendererViewForHeaderInSection() {
        // Given
        let section = Section(header: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)

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
        let section = Section(header: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)
        let header = tableView.headerView(forSection: 0)

        // Then
        XCTAssert(header is TestHeaderFooterView)
    }

    func testTableViewInvalidModelViewForSection() {
        // Given
        let section = Section(header: nil)

        // When
        renderer.updateSections([section], animation: .none)
        let header = tableView.headerView(forSection: 0)

        // Then
        XCTAssertNil(header)
    }

    func testRendererSwiftUIViewForHeaderInSection() {
        // Given
        let section = Section(header: TestViewComponent(title: "Test"))

        // When
        renderer.updateSections([section], animation: .none)

        // Then
        do {
            let header = try renderer.headerView(for: tableView, inSection: 0)
            XCTAssert(header is SwiftUIHostingTableHeaderFooterView)
        } catch {
            XCTAssert(false)
        }
    }

    // MARK: - Footer

    func testRendererViewForFooterInSection() {
        // Given
        let section = Section(footer: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)

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
        let section = Section(footer: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)
        let footer = tableView.footerView(forSection: 0)

        // Then
        XCTAssert(footer is TestHeaderFooterView)
    }

    func testRendererSwiftUIViewForFooterInSection() {
        // Given
        let section = Section(header: TestViewComponent(title: "Test"))

        // When
        renderer.updateSections([section], animation: .none)

        // Then
        do {
            let header = try renderer.headerView(for: tableView, inSection: 0)
            XCTAssert(header is SwiftUIHostingTableHeaderFooterView)
        } catch {
            XCTAssert(false)
        }
    }

    // MARK: - Cell

    func testRendererClassCellForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

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
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(cell is TestComponentCell)
    }

    func testRendererNibCellForRowAt() {
        // Given
        let row = TestNibComponentViewModel()

        // When
        renderer.updateRows([row])

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
        let row = TestNibComponentViewModel()

        // When
        renderer.updateRows([row])
        let cell = tableView.cellForRow(
            at: IndexPath(row: 0, section: 0)) as? TestNibComponentViewCell

        // Then
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell?.testLabel)
    }

    func testRendererCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView()

        // When
        renderer.sections = [Section(rows: [row])]
        tableView.register(TestComponentInvalidCell.self, forCellReuseIdentifier: "TestComponentInvalidCell")

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView,
                                           at: IndexPath(row: 0, section: 0))
            XCTAssert(false)
        } catch let error {
            if case .viewModelNotRegistered = error.as(BlocksError.self) {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

    func testTableViewCellForRowAtInvalidView() {
        // Given
        let row = TestComponentInvalidView()

        // When
        renderer.sections = [Section(rows: [row])]
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(cell == nil)
    }

    func testRendererSwiftUICellForRowAt() {
        // Given
        let row = TestViewComponent(title: "test")

        // When
        renderer.updateRows([row])

        // Then
        do {
            let cell = try self.renderer.cellView(for: tableView,
                                                  at: IndexPath(row: 0, section: 0))
            XCTAssert(cell is SwiftUIHostingTableViewCell)
        } catch {
            XCTAssert(false)
        }
    }

    func testRendererCallbeforeReuse() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

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
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentViewModel.beforeReuseCalled)
    }

    func testRendererCellSetTableView() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

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
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

        // Then
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssert(TestComponentCell.tableView == renderer.tableView)
    }

    func testRendererCellForRowCallsConfigure() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

        // Then
        do {
            _ = try self.renderer.cellView(for: tableView, at: IndexPath(row: 0, section: 0))
            XCTAssert(TestComponentCell.configureCalled)
        } catch {
            XCTAssert(false)
        }
    }

    func testTableViewCellForRowCallsConfigure() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssert(TestComponentCell.configureCalled)
    }

    func testRendererHeightForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

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
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])
        let cell = self.renderer.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let size = cell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        // Then
        XCTAssert(Int(size.height) == 152)
    }

    func testRendererHeightForHeaderInSection() {
        // Given
        let section = [Section(header: TestHeaderFooterComponentViewModel())]

        // When
        renderer.updateSections(section,
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
        let section = [Section(header: TestHeaderFooterComponentViewModel())]

        // When
        renderer.updateSections(section,
                             animation: .none)

        // Then
        let header = renderer.tableView(tableView, viewForHeaderInSection: 0)
        let size = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    func testRendererHeightForFooterInSection() {
        // Given
        let section = Section(footer: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)

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
        let section = Section(footer: TestHeaderFooterComponentViewModel())

        // When
        renderer.updateSections([section], animation: .none)

        // Then
        let footer = self.renderer.tableView.footerView(forSection: 0)
        let size = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero

        XCTAssert(Int(size.height) == 152)
    }

    // MARK: - Estimated Heights

    func testEstimatedHeightForRowAt() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView,
                                                 estimatedHeightForRowAt: IndexPath(row: 0, section: 0))

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testEstimatedHeightForHeaderInSection() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testEstimatedHeightForFooterInSection() {
        // Given
        let row = TestComponentViewModel()

        // When
        renderer.updateRows([row])

        // Then
        let estimatedHeight = renderer.tableView(tableView, estimatedHeightForFooterInSection: 0)

        XCTAssert(estimatedHeight == UITableView.automaticDimension)
    }

    func testEstimatedCellHeight() {
        // Given
        let row = TestComponentViewModel()
        renderer.estimatedHeightForRowComponent = { $0 is TestComponentViewModel ? 50 : 0 }

        // When
        renderer.updateRows([row])
        let estimatedHeight = renderer.tableView(renderer.tableView, estimatedHeightForRowAt: .init(row: 0, section: 0))

        // Then
        XCTAssertEqual(estimatedHeight, 50)
    }

    func testEstimatedHeaderHeight() {
        // Given
        let header = TestHeaderFooterComponentViewModel()
        renderer.estimatedHeightForHeaderComponent = { $0 is TestHeaderFooterComponentViewModel ? 13.5 : 0 }

        // When
        renderer.updateSections([Section(header: header)], animation: .none)
        let estimatedHeight = renderer.tableView(renderer.tableView, estimatedHeightForHeaderInSection: 0)

        // Then
        XCTAssertEqual(estimatedHeight, 13.5)
    }

    func testEstimatedFooterHeight() {
        // Given
        let footer = TestHeaderFooterComponentViewModel()
        renderer.estimatedHeightForFooterComponent = { $0 is TestHeaderFooterComponentViewModel ? 99.5 : 0 }

        // When
        renderer.updateSections([Section(footer: footer)], animation: .none)
        let estimatedHeight = renderer.tableView(renderer.tableView, estimatedHeightForFooterInSection: 0)

        // Then
        XCTAssertEqual(estimatedHeight, 99.5)
    }

    func testEstimatedHeightsAuto() {
        // Given
        let header = TestHeaderFooterComponentViewModel()
        let footer = TestHeaderFooterComponentViewModel()
        let cell = TestComponentViewModel()

        renderer.estimatedHeightForRowComponent = nil
        renderer.estimatedHeightForHeaderComponent = nil
        renderer.estimatedHeightForFooterComponent = nil

        // When
        renderer.updateSections([Section(header: header, footer: footer, rows: [cell])], animation: .none)

        // Then
        let estimatedHeaderHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForHeaderInSection: 0)
        let estimatedFooterHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForFooterInSection: 0)
        let estimatedRowHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForRowAt: .init(row: 0, section: 0))

        XCTAssertEqual(estimatedHeaderHeight, UITableView.automaticDimension)
        XCTAssertEqual(estimatedFooterHeight, UITableView.automaticDimension)
        XCTAssertEqual(estimatedRowHeight, UITableView.automaticDimension)
    }

    func testAllEstimatedHeightsSimultaneously() {
        // Given
        let header = TestHeaderFooterComponentViewModel()
        let footer = TestHeaderFooterComponentViewModel()
        let cell = TestComponentViewModel()

        renderer.estimatedHeightForRowComponent = { $0 is TestComponentViewModel ? 3 : 0 }
        renderer.estimatedHeightForHeaderComponent = { $0 is TestHeaderFooterComponentViewModel ? 2 : 0 }
        renderer.estimatedHeightForFooterComponent = { $0 is TestHeaderFooterComponentViewModel ? 1 : 0 }

        // When
        renderer.updateSections([Section(header: header, footer: footer, rows: [cell])], animation: .none)

        // Then
        let estimatedHeaderHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForHeaderInSection: 0)
        let estimatedFooterHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForFooterInSection: 0)
        let estimatedRowHeight = renderer.tableView(
            renderer.tableView,
            estimatedHeightForRowAt: .init(row: 0, section: 0))

        XCTAssertEqual(estimatedHeaderHeight, 2)
        XCTAssertEqual(estimatedFooterHeight, 1)
        XCTAssertEqual(estimatedRowHeight, 3)
    }
}

// swiftlint:enable file_length type_body_length
