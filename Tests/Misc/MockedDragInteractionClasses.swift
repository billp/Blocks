// MockedDragInteractionClasses.swift
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

import Foundation
import UIKit

class MockTableView: UITableView {
    var mockHasActiveDrag: Bool = false

    override var hasActiveDrag: Bool {
        return mockHasActiveDrag
    }
}

class MockDragSession: NSObject, UIDragSession {
    var destinationIndexPath: IndexPath?
    var allowsMoveOperation: Bool = true
    var isRestrictedToDraggingApplication: Bool = true
    var localContext: Any?
    var items: [UIDragItem] = []

    func canLoadObjects(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        false
    }

    func location(in view: UIView) -> CGPoint {
        .zero
    }

    func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        false
    }

    override init() {
        super.init()
    }

    init(destinationIndexPath: IndexPath, dragItems: [UIDragItem]) {
        self.destinationIndexPath = destinationIndexPath
        self.items = dragItems
    }
}

class MockDropCoordinator: NSObject, UITableViewDropCoordinator {
    var sourceIndexPath: IndexPath?
    var destinationIndexPath: IndexPath?
    var dragItems: [UIDragItem]
    var dropProposal: UITableViewDropProposal

    func drop(_ dragItem: UIDragItem, toRowAt indexPath: IndexPath) -> UIDragAnimating {
        MockDragAnimating()
    }

    func drop(_ dragItem: UIDragItem, intoRowAt indexPath: IndexPath, rect: CGRect) -> UIDragAnimating {
        MockDragAnimating()
    }

    func drop(_ dragItem: UIDragItem, to placeholder: UITableViewDropPlaceholder) -> UITableViewDropPlaceholderContext {
        MockDropPlaceholderContext()
    }

    func drop(_ dragItem: UIDragItem, to target: UIDragPreviewTarget) -> UIDragAnimating {
        MockDragAnimating()
    }

    init(sourceIndexPath: IndexPath,
         destinationIndexPath: IndexPath,
         items: [UIDragItem],
         proposal: UITableViewDropProposal) {
        self.sourceIndexPath = sourceIndexPath
        self.destinationIndexPath = destinationIndexPath
        self.dragItems = items
        self.dropProposal = proposal
    }

    var items: [UITableViewDropItem] {
        return dragItems.map { item in
            MockDropItem(dragItem: item, indexPath: sourceIndexPath!)
        }
    }

    var proposal: UITableViewDropProposal {
        return dropProposal
    }

    var session: UIDropSession {
        return MockDropSession()
    }

    func drop(_ dragItem: UIDragItem, to placeholder: UITableViewDropPlaceholder) {

    }
}

class MockDropItem: NSObject, UITableViewDropItem {
    var sourceIndexPath: IndexPath?
    var previewSize: CGSize
    var dragItem: UIDragItem

    init(dragItem: UIDragItem, indexPath: IndexPath) {
        self.dragItem = dragItem
        self.sourceIndexPath = indexPath
        self.previewSize = .init()
    }

    var itemProvider: NSItemProvider {
        return dragItem.itemProvider
    }
}

class MockDragAnimating: NSObject, UIDragAnimating {
    func addAnimations(_ animations: @escaping () -> Void) {
    }

    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
    }
}

class MockDropPlaceholderContext: NSObject, UITableViewDropPlaceholderContext {
    var dragItem: UIDragItem = .init(itemProvider: .init())

    func commitInsertion(dataSourceUpdates: (IndexPath) -> Void) -> Bool {
        false
    }

    func deletePlaceholder() -> Bool {
        false
    }

    func addAnimations(_ animations: @escaping () -> Void) { }

    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) { }
}

class MockDropSession: NSObject, UIDropSession {
    var localDragSession: UIDragSession?
    var progressIndicatorStyle: UIDropSessionProgressIndicatorStyle = .default
    var items: [UIDragItem] = []
    var allowsMoveOperation: Bool = false
    var isRestrictedToDraggingApplication: Bool = false
    var progress: Progress = .discreteProgress(totalUnitCount: 0)

    func loadObjects(ofClass aClass: NSItemProviderReading.Type,
                     completion: @escaping ([NSItemProviderReading]) -> Void) -> Progress {
        .discreteProgress(totalUnitCount: 0)
    }

    func canLoadObjects(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        false
    }

    override init() {
        super.init()
    }

    init(dropItems: [UIDragItem]) {
        self.items = dropItems
    }

    func location(in view: UIView) -> CGPoint {
        .init()
    }

    func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        false
    }
}
