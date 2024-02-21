// DragDropInteractionTests.swift
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

class DragDropInteractionTests: XCTestCase {
    lazy var sampleViewController: SampleViewController = {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let viewController = SampleViewController()
        viewController.view.bounds = window.bounds
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return viewController
    }()

    var tableView: MockTableView {
        sampleViewController.tableView
    }

    lazy var renderer: TableViewRenderer = {
        let renderer = TableViewRenderer(tableView: tableView, bundle: Bundle(for: Self.self))
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

    func testEnablingDragInteraction() {
        // Given
        renderer.dragEnabled = false

        // When
        renderer.dragEnabled = true

        // Then
        XCTAssertTrue(renderer.tableView.dragInteractionEnabled,
                      "TableView's dragInteractionEnabled should be enabled.")
        XCTAssertNotNil(renderer.tableView.dropDelegate,
                        "TableView's dropDelegate should not be nil.")
        XCTAssertNotNil(renderer.tableView.dragDelegate,
                        "TableView's dragDelegate should not be nil.")
    }

    func testDisablingDragInteraction() {
        // Given
        renderer.dragEnabled = true

        // When
        renderer.dragEnabled = false

        // Then
        XCTAssertFalse(renderer.tableView.dragInteractionEnabled,
                       "TableView's dragInteractionEnabled should be disabled.")
        XCTAssertNil(renderer.tableView.dropDelegate,
                     "TableView's dropDelegate should be nil.")
        XCTAssertNil(renderer.tableView.dragDelegate,
                     "TableView's dragDelegate should be nil.")
    }

    func testDragStartedCalledOnDragOperation() {
        // Given
        var dragStartedCalled = false

        renderer.dragStarted = {
            dragStartedCalled = true
        }

        // When
        _ = renderer.tableView(tableView, itemsForBeginning: MockDragSession(), at: .init(row: 0, section: 0))

        // Then
        XCTAssertTrue(dragStartedCalled, "Drag started closure should be called during drag operation.")
    }

    func testCanDragClosurePreventsDragForSpecificItem() {
        // Given
        renderer.canDrag = { _, _ in false }

        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)

        // When
        let dragItems = renderer.tableView(tableView, itemsForBeginning: MockDragSession(), at: indexPath)

        // Then
        XCTAssertTrue(dragItems.isEmpty, "Drag items should be empty when canDrag returns false.")
    }

    func testCanDragClosureAllowsDragForSpecificItem() {
        // Given
        renderer.canDrag = { _, _ in true }

        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)

        // When
        let dragItems = renderer.tableView(tableView, itemsForBeginning: MockDragSession(), at: indexPath)

        // Then
        XCTAssertFalse(dragItems.isEmpty, "Drag items should not be empty when canDrag returns true.")
        XCTAssertEqual(dragItems.count, 1, "There should be exactly one drag item.")
    }

    func testDragAndDropHandling() {
        // Given
        let sourceIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 1, section: 0)

        let initialComponent = renderer.sections[0].rows![0]

        // When
        let expectation = self.expectation(description: "Update main queue.")
        UIView.performWithoutAnimation { [weak self] in
            self?.simulateDragAndDrop(from: sourceIndexPath, to: destinationIndexPath)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        let resultingComponent = renderer.sections[0].rows![1]
        XCTAssertEqual(Box(initialComponent).hashValue, Box(resultingComponent).hashValue,
                       "Component should have moved to the new index path.")
        XCTAssertNotEqual(Box(renderer.sections[0].rows![0]).hashValue, Box(initialComponent).hashValue,
                          "Original position should not have the same component after the move.")
    }

    func testCanDropReturnsTrue() {
        // Given
        let sourceIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 1, section: 0)
        renderer.canDrag = { _, _ in true }
        renderer.canDrop = { _, _ in true }

        // When
        tableView.mockHasActiveDrag = true
        _ = renderer.tableView(tableView, itemsForBeginning: MockDragSession(), at: sourceIndexPath)

        let dropProposal = renderer.tableView(
            renderer.tableView,
            dropSessionDidUpdate: MockDropSession(dropItems: [.init(itemProvider: .init())]),
            withDestinationIndexPath: destinationIndexPath)
        tableView.mockHasActiveDrag = false

        // Then
        XCTAssertEqual(dropProposal.operation,
                       .move,
                       "Drop proposal operation should be .move when canDrop returns true.")
    }

    func testCanDropReturnsFalse() {
        // Given
        let sourceIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 1, section: 0)
        renderer.canDrag = { _, _ in true }
        renderer.canDrop = { _, _ in false }

        // When
        tableView.mockHasActiveDrag = true
        _ = renderer.tableView(tableView, itemsForBeginning: MockDragSession(), at: sourceIndexPath)

        let dropProposal = renderer.tableView(
            renderer.tableView,
            dropSessionDidUpdate: MockDropSession(dropItems: [.init(itemProvider: .init())]),
            withDestinationIndexPath: destinationIndexPath)
        tableView.mockHasActiveDrag = false

        // Then
        XCTAssertEqual(dropProposal.operation,
                       .cancel,
                       "Drop proposal operation should be .cancel when canDrop returns false.")
    }

    func testDropCompletedClosureCalled() {
        // Given
        let sourceIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 1, section: 0)
        renderer.canDrag = { _, _ in true }
        renderer.canDrop = { _, _ in true }

        var dropCompletedCalled = false
        var dropSourceIndexPath: IndexPath?
        var dropDestinationIndexPath: IndexPath?

        renderer.dropCompleted = { source, destination in
            dropCompletedCalled = true
            dropSourceIndexPath = source
            dropDestinationIndexPath = destination
        }

        // When
        let expectation = self.expectation(description: "Update main queue.")
        UIView.performWithoutAnimation { [weak self] in
            self?.simulateDragAndDrop(from: sourceIndexPath, to: destinationIndexPath)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(dropCompletedCalled, "Drop completed closure should be called.")
        XCTAssertEqual(dropSourceIndexPath, sourceIndexPath, "Source index path should match.")
        XCTAssertEqual(dropDestinationIndexPath, destinationIndexPath, "Destination index path should match.")
    }

    func testCustomizeDragPreviewForComponent() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        let expectedProperties = DragViewMaskProperties(top: 10, right: 10, bottom: 10, left: 10, cornerRadius: 5)
        renderer.customizeDragPreviewForComponent = { _ in return expectedProperties }

        guard let previewParameters = renderer.tableView(tableView, dragPreviewParametersForRowAt: indexPath) else {
            XCTFail("Expected drag preview parameters to be non-nil")
            return
        }
        guard var frame = tableView.cellForRow(at: indexPath)?.contentView.frame else {
            XCTFail("frame to be non-nil")
            return
        }

        // When
        frame.origin.x += expectedProperties.left
        frame.origin.y += expectedProperties.top
        frame.size.width -= expectedProperties.left + expectedProperties.right
        frame.size.height -= expectedProperties.top + expectedProperties.bottom

        let expectedPath = UIBezierPath(roundedRect: frame, cornerRadius: expectedProperties.cornerRadius)

        // Then
        XCTAssertEqual(previewParameters.visiblePath?.cgPath.boundingBox,
                       expectedPath.cgPath.boundingBox,
                       "The visible path's bounding box should match the expected path's bounding box.")
    }
}

extension DragDropInteractionTests {
    private func simulateDragAndDrop(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Mock the process of starting a drag operation
        let mockSession = MockDragSession()
        let dragItems = renderer.tableView(tableView, itemsForBeginning: mockSession, at: sourceIndexPath)

        guard !dragItems.isEmpty else { return }

        // Mock the drop operation, directly invoking the logic that would be triggered by the drop
        let mockDropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        let mockDropCoordinator = MockDropCoordinator(sourceIndexPath: sourceIndexPath,
                                                      destinationIndexPath: destinationIndexPath,
                                                      items: dragItems,
                                                      proposal: mockDropProposal)

        renderer.tableView(tableView, performDropWith: mockDropCoordinator)
    }
}
