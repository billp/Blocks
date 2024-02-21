// SectionsTest.swift
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

class SectionsTest: XCTestCase {
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
        renderer.register(viewModelType: MyLabelComponent.self, classType: LabelViewCell.self)
        renderer.register(viewModelType: MyHeaderFooterComponent.self, classType: MyHeaderFooterView.self)
        renderer.register(viewModelType: MyButtonComponent.self, classType: ButtonViewCell.self)

        return renderer
    }()

    func testOnAppendSection() {
        // Given
        let initialSection = Section(
            header: MyHeaderFooterComponent(title: "Header 1"),
            footer: MyHeaderFooterComponent(title: "Footer 1"),
            rows: [
                MyLabelComponent(title: "Row 1"),
                MyLabelComponent(title: "Row 2"),
                MyLabelComponent(title: "Row 3"),
                MyButtonComponent(title: "Button 1", onTap: { print("Button 1 tapped") })
            ]
        )

        let newSection = Section(
            header: MyHeaderFooterComponent(title: "Header 3"),
            footer: MyHeaderFooterComponent(title: "Footer 3"),
            rows: [
                MyLabelComponent(title: "Row 7"),
                MyLabelComponent(title: "Row 8")
            ]
        )

        renderer.updateSections([initialSection], animation: .none)

        // When
        renderer.appendSection(newSection, with: .none)

        // Then
        let headerView = tableView.headerView(forSection: 1) as? MyHeaderFooterView
        let footerView = tableView.footerView(forSection: 1) as? MyHeaderFooterView
        XCTAssertNotNil(headerView)
        XCTAssertNotNil(footerView)
        XCTAssertEqual(headerView?.label.text, "Header 3")
        XCTAssertEqual(footerView?.label.text, "Footer 3")

        // Verify cells for the new section
        let expectedRowCount = newSection.rows?.count ?? 0
        for rowIndex in 0..<expectedRowCount {
            let indexPath = IndexPath(row: rowIndex, section: 1)
            guard let cell = tableView.cellForRow(at: indexPath) as? LabelViewCell else {
                XCTFail("Expected \(LabelViewCell.self) not found at row \(rowIndex) in section 1")
                return
            }

            let expectedTitle = (newSection.rows?[rowIndex] as? MyLabelComponent)?.title ?? ""
            XCTAssertEqual(
                cell.textLabel?.text,
                expectedTitle,
                "Cell title does not match expected title at row \(rowIndex) in section 1")
        }
    }

    func testOnInsertSection() {
        // Given
        let initialSection = createInitialSection()
        let newSection = createNewSectionWithTitle("New Inserted Header")

        renderer.updateSections([initialSection], animation: .none)

        // When
        renderer.insertSection(newSection, at: 0, with: .none)

        // Then
        verifySection(atIndex: 0,
                      withHeaderTitle: "New Inserted Header",
                      footerTitle: "New Inserted Footer",
                      expectedRowCount: 2)
    }

    func testOnInsertSections() {
        // Given
        let initialSection = createInitialSection()
        let newSections = [
            createNewSectionWithTitle("Inserted Header 1"),
            createNewSectionWithTitle("Inserted Header 2")
        ]

        renderer.updateSections([initialSection], animation: .none)

        // When
        renderer.insertSections(newSections, at: 1, with: .none)

        // Then
        for (index, section) in newSections.enumerated() {
            verifySection(
                atIndex: index + 1,
                withHeaderTitle: (section.header as? MyHeaderFooterComponent)?.title ?? "",
                footerTitle: (section.footer as? MyHeaderFooterComponent)?.title ?? "",
                expectedRowCount: section.rows?.count ?? 0)
        }
    }

    func testOnRemoveSection() {
        // Given
        let sections = [
            createNewSectionWithTitle("Header 1"),
            createNewSectionWithTitle("Header 2")
        ]

        renderer.updateSections(sections, animation: .none)

        // When
        renderer.removeSection(at: 0, with: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        let remainingHeaderView = tableView.headerView(forSection: 0) as? MyHeaderFooterView
        XCTAssertEqual(remainingHeaderView?.label.text, "Header 2")
    }

    func testOnRemoveSections() {
        // Given
        let sections = [
            createNewSectionWithTitle("Header to Remove 1"),
            createNewSectionWithTitle("Header to Keep"),
            createNewSectionWithTitle("Header to Remove 2")
        ]

        renderer.updateSections(sections, animation: .none)

        // When
        renderer.removeSections(
            where: { ($0.header as? MyHeaderFooterComponent)?.title.contains("to Remove") == true },
            with: .none)

        // Then
        XCTAssertEqual(tableView.numberOfSections, 1)
        let remainingHeaderView = tableView.headerView(forSection: 0) as? MyHeaderFooterView
        XCTAssertEqual(remainingHeaderView?.label.text, "Header to Keep")
    }

}

private extension SectionsTest {
    func createInitialSection() -> Section {
        return Section(
            header: MyHeaderFooterComponent(title: "Initial Header"),
            footer: MyHeaderFooterComponent(title: "Initial Footer"),
            rows: [MyLabelComponent(title: "Initial Row 1"),
                   MyLabelComponent(title: "Initial Row 2")]
        )
    }

    func createNewSectionWithTitle(_ title: String) -> Section {
        return Section(
            header: MyHeaderFooterComponent(title: title),
            footer: MyHeaderFooterComponent(title: title.replacingOccurrences(of: "Header", with: "Footer")),
            rows: [MyLabelComponent(title: "\(title) Row 1"),
                   MyLabelComponent(title: "\(title) Row 2")]
        )
    }

    func verifySection(atIndex index: Int,
                       withHeaderTitle headerTitle: String,
                       footerTitle: String, expectedRowCount: Int) {
        let headerView = tableView.headerView(forSection: index) as? MyHeaderFooterView
        let footerView = tableView.footerView(forSection: index) as? MyHeaderFooterView
        XCTAssertNotNil(headerView)
        XCTAssertNotNil(footerView)
        XCTAssertEqual(headerView?.label.text, headerTitle)
        XCTAssertEqual(footerView?.label.text, footerTitle)
        XCTAssertEqual(tableView.numberOfRows(inSection: index), expectedRowCount)
    }
}
