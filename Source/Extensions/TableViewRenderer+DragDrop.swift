// TableViewRenderer+DragDrop.swift
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

extension TableViewRenderer: UITableViewDragDelegate, UITableViewDropDelegate {
    public func tableView(_ tableView: UITableView,
                          itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath) -> [UIDragItem] {
        guard let component = sections[indexPath.section].rows?[indexPath.row],
                canDrag(indexPath, component) else {
            return []
        }

        dragSourceIndexPath = indexPath

        let itemProvider = NSItemProvider(object: String(component.hashValue) as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        dragStarted?()

        return [dragItem]
    }

    public func tableView(_ tableView: UITableView,
                          dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard var frame = tableView.cellForRow(at: indexPath)?.contentView.frame,
              let component = sections[indexPath.section].rows?[indexPath.row],
              let dragViewMaskProperties = customizeDragPreviewForComponent?(component) else {
            return nil
        }

        frame.origin.x += dragViewMaskProperties.left
        frame.origin.y += dragViewMaskProperties.top
        frame.size.width -= dragViewMaskProperties.left + dragViewMaskProperties.right
        frame.size.height -= dragViewMaskProperties.top + dragViewMaskProperties.bottom

        let previewParameters = UIDragPreviewParameters()

        let path = UIBezierPath(roundedRect: frame, cornerRadius: dragViewMaskProperties.cornerRadius)
        previewParameters.visiblePath = path
        return previewParameters
    }

    public func tableView(_ tableView: UITableView,
                          performDropWith coordinator: UITableViewDropCoordinator) {

        guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else {
            return
        }

        guard let sourceItem = sections[sourceIndexPath.section].rows?[sourceIndexPath.row] else { return }

        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Default to the last section, last row
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        var newSections = sections

        newSections[sourceIndexPath.section].rows?.remove(at: sourceIndexPath.row)
        updateSections(newSections, animation: .automatic)

        var destinationRows = newSections[destinationIndexPath.section].rows ?? []
        destinationRows.insert(sourceItem, at: destinationIndexPath.row)
        newSections[destinationIndexPath.section].rows = destinationRows

        updateSections(newSections, animation: .fade)

        dropCompleted?(sourceIndexPath, destinationIndexPath)
    }

    public func tableView(_ tableView: UITableView,
                          dropSessionDidUpdate session: UIDropSession,
                          withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)

        guard let destinationIndexPath,
              let dragSourceIndexPath,
              canDrop(dragSourceIndexPath, destinationIndexPath) else { return dropProposal }

        // Accept only one drag item.
        guard session.items.count == 1 else { return dropProposal }

        if tableView.hasActiveDrag {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return dropProposal
    }
}
