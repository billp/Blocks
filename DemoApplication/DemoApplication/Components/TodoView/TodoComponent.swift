// TodoComponent.swift
//
// Copyright © 2021-2023 Vassilis Panagiotopoulos. All rights reserved.
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
import Blocks
import SwiftUI
import Combine

class TodoComponent: ObservableObject, Component {
    // MARK: - Properties

    @Published var offsetX = 0.0
    @Published var scale: CGFloat = 0.5
    @Published var completed: Bool = false
    @Published var position: TodoPosition = .middle

    var roundedCorners: UIRectCorner {
        roundedCorners(for: position)
    }

    var shouldAddSeparator: Bool {
        ![.last, .none].contains(position)
    }

    private var isSwipeMenuOpened: Bool = false

    var completedChangedPublisher = PassthroughSubject<TodoComponent, Never>()
    var deleteActionPublisher = PassthroughSubject<TodoComponent, Never>()

    var id: UUID
    var title: String

    init(todo: Todo) {
        self.id = todo.id
        self.title = todo.title
        self.completed = todo.completed
    }

    // MARK: - Actions

    func deleteAction() {
        scale = 0
        offsetX = 0
        deleteActionPublisher.send(self)
    }

    // MARK: - Swipe menu

    func dragGestureOnChange(_ gesture: DragGesture.Value) {
        let width = gesture.translation.width
        let swipeMenuItemWidthWithPadding = Constants.swipeMenuItemWidth + Constants.swipeMenuItemPadding

        if isSwipeMenuOpened && width > swipeMenuItemWidthWithPadding {
            offsetX = 0
            return
        } else if !isSwipeMenuOpened && width > 0 {
            offsetX = 0
            return
        }

        if isSwipeMenuOpened {
            offsetX = width - swipeMenuItemWidthWithPadding
        } else {
            offsetX = width
        }
    }

    func dragGestureEnded(_ gesture: DragGesture.Value) {
        let width = gesture.translation.width
        let swipeMenuItemWidthWithPadding = Constants.swipeMenuItemWidth + Constants.swipeMenuItemPadding

        if width < -swipeMenuItemWidthWithPadding/2.0 {
            isSwipeMenuOpened = true
            offsetX = -swipeMenuItemWidthWithPadding
        } else {
            swipeReset()
        }
    }

    func swipeReset() {
        isSwipeMenuOpened = false
        offsetX = 0
    }

    // MARK: - Helpers

    func toggleCompleted() {
        guard scale == 1 else { return }

        self.completed.toggle()

        if completed {
            applyCompletedAnimation()
        } else {
            completedChangedPublisher.send(self)
        }
    }

    private func roundedCorners(for position: TodoPosition) -> UIRectCorner {
        switch position {
        case .first:
            return [.topLeft, .topRight]
        case .last:
            return [.bottomLeft, .bottomRight]
        case .middle:
            return []
        case .none:
            return [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
    }

    private func applyCompletedAnimation() {
        withAnimation(.spring(duration: Constants.toggleAnimationDuration)) {
            scale = Constants.toggleAnimationCompletedMaxScale
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toggleAnimationDuration) { [weak self] in
            guard let self else { return }
            withAnimation(.spring(duration: Constants.toggleAnimationDuration)) { 
                self.scale = Constants.toggleAnimationEndScale
            }
            self.completedChangedPublisher.send(self)
        }
    }
}

// MARK: - Hashable and Equatable

extension TodoComponent {
    static func == (lhs: TodoComponent, rhs: TodoComponent) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}

// MARK: - Constants

extension TodoComponent {
    enum Constants {
        static var toggleAnimationDuration = 0.3
        static var toggleAnimationCompletedMaxScale = 1.1
        static var toggleAnimationEndScale = 1.0
        static var swipeMenuItemWidth = 35.0
        static var swipeMenuItemCount = 1
        static var swipeMenuItemPadding = 20.0
    }
}

// MARK: - Enums

extension TodoComponent {
    enum TodoPosition {
        case first
        case last
        case middle
        case none
    }
}
