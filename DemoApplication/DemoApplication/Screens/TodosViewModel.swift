// TodosViewModel.swift
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
import Blocks
import Combine

class TodosViewModel {
    // MARK: - Properties

    private weak var renderer: TableViewRenderer?
    private var activeTodos: [TodoComponent] = []
    private var disposableBag = Set<AnyCancellable>()
    private var completedTodos: [TodoComponent] = []
    private var todoInputField = TodoTextFieldComponent(placeholder: NSLocalizedString("What's next?",
                                                                                       comment: ""))

    // MARK: - Initializers

    init(with renderer: TableViewRenderer) {
        self.renderer = renderer
        setupTextFieldBindings()
    }

    // MARK: - Lifecycle

    func configureScreen() {
        setupDragNDrop()
        updateSections(activeTodos: [],
                       completedTodos: [])
    }

    // MARK: - Actions

    func addSamples() {
        let mockTodos: [String] = [
            "Finish SwiftUI project",
            "Grocery shopping",
            "Call the bank",
            "Book dentist appointment",
            "Plan weekend getaway",
            "Update resume",
            "Read SwiftUI documentation",
            "Organize office desk"
        ]

        mockTodos.forEach(addTodo)

        updateSections(activeTodos: activeTodos, 
                       completedTodos: completedTodos,
                       animated: true)
    }

    private func addTodo(_ title: String) {
        guard !title.isEmpty else { return }

        let todoComponent = TodoComponent(todo: .init(title: title, completed: false))
        setupTodoBindings(todoComponent)
        activeTodos.append(todoComponent)

        // Clear input
        DispatchQueue.main.async { [weak self] in
            self?.todoInputField.value = ""
        }

        updateSections(activeTodos: activeTodos,
                       completedTodos: completedTodos)
    }

    // MARK: - Helpers

    private func setupTextFieldBindings() {
        self.todoInputField
            .onReturnPublisher
            .sink(receiveValue: addTodo)
            .store(in: &disposableBag)
    }

    private func setupTodoBindings(_ todoComponent: TodoComponent) {
        todoComponent
            .completedChangedPublisher
            .sink(receiveValue: handleCompletedChanged)
            .store(in: &disposableBag)
        todoComponent
            .deleteActionPublisher
            .sink(receiveValue: handleDeletion)
            .store(in: &disposableBag)
    }

    private func setupDragNDrop() {
        renderer?.customizeDragPreviewForComponent = { component in
            return .init(top: 2, right: 20, bottom: 2, left: 20, cornerRadius: 5)
        }

        renderer?.dragStarted = { [weak self] in
            self?.closeAllSwipeMenus()
        }

        renderer?.canDrag = { _, component in
            return component is TodoComponent
        }

        renderer?.dropCompleted = { [weak self] sourceIndexPath, destinationIndexPath in
            guard let self else { return }
            guard let section = renderer?.sections[sourceIndexPath.section] else {
                return
            }

            switch section.id as? String {
            case Constants.activeTodosSectionId:
                activeTodos = section
                    .rows?
                    .filter { $0 is TodoComponent }
                    .map { $0.as(TodoComponent.self) } ?? []
            case Constants.completedTodosSectionId:
                completedTodos = section
                    .rows?
                    .filter { $0 is TodoComponent }
                    .map { $0.as(TodoComponent.self) } ?? []
            default:
                break
            }

            updateTodoPositions(self.activeTodos)
            updateTodoPositions(self.completedTodos)
        }

        renderer?.canDrop = { [weak self] sourceIndexPath, destinationIndexPath in
            guard let self else { return false }
            guard let sourceSection = renderer?.sections[sourceIndexPath.section],
                  let destinationSection = renderer?.sections[destinationIndexPath.section],
                    sourceSection == destinationSection else {
                        return false
                    }

            switch sourceSection.id as? String {
            case Constants.activeTodosSectionId:
                return destinationIndexPath.row < activeTodos.count && sourceIndexPath.row != activeTodos.count
            case Constants.completedTodosSectionId:
                return destinationIndexPath.row < completedTodos.count && sourceIndexPath.row != completedTodos.count
            default:
                return false
            }
        }
    }

    private func updateSections(activeTodos: [TodoComponent],
                                completedTodos: [TodoComponent],
                                animated: Bool = false) {
        self.activeTodos = activeTodos
        self.completedTodos = completedTodos

        updateTodoPositions(activeTodos)
        updateTodoPositions(completedTodos)

        let newSections = [
            Section(
                id: Constants.textFieldSectionId,
                rows: [todoInputField, RowSpacer(type: .fixed(15))]
            ),
            Section(
                id: Constants.activeTodosSectionId,
                header: TodoListHeaderComponent(title: NSLocalizedString("Active", comment: ""), 
                                        imageName: "checklist.unchecked"),
                rows: createActiveTodos(activeTodos)
            ),
            Section(
                id: Constants.completedTodosSectionId,
                header: TodoListHeaderComponent(title: NSLocalizedString("Completed", comment: ""), 
                                        imageName: "checklist.checked"),
                rows: createCompletedTodos(completedTodos)
            )
        ]

        renderer?.updateSections(newSections, animation: animated ? .fade : .none)
    }

    private func createActiveTodos(_ todos: [TodoComponent]) -> [any Component] {
        if todos.isEmpty {
            return [EmptyResultsComponent(title: "No active todos.")]
        }

        return todos + [RowSpacer(type: .fixed(15))]
    }

    private func createCompletedTodos(_ todos: [TodoComponent]) -> [any Component] {
        if todos.isEmpty {
            return [EmptyResultsComponent(title: "No completed todos.")]
        }

        return todos
    }

    private func updateTodoPositions(_ todos: [TodoComponent]) {
        if todos.count == 1 {
            todos.first?.position = .none
        } else {
            todos.forEach({ $0.position = .middle })
            todos.first?.position = .first
            todos.last?.position = .last
        }
    }

    private func handleCompletedChanged(_ todoComponent: TodoComponent) {
        if todoComponent.completed {
            moveTodoToCompleted(todoComponent)
        } else {
            moveTodoToActive(todoComponent)
        }
    }

    private func handleDeletion(_ todoComponent: TodoComponent) {
        activeTodos.removeAll(where: { $0 == todoComponent })
        completedTodos.removeAll(where: { $0 == todoComponent })

        updateSections(activeTodos: activeTodos,
                       completedTodos: completedTodos,
                       animated: true)
    }

    private func moveTodoToActive(_ todoComponent: TodoComponent) {
        completedTodos.removeAll(where: { $0 == todoComponent })
        activeTodos.append(todoComponent)

        updateSections(activeTodos: activeTodos,
                       completedTodos: completedTodos,
                       animated: true)
    }

    private func moveTodoToCompleted(_ todoComponent: TodoComponent) {
        activeTodos.removeAll(where: { $0 == todoComponent })
        completedTodos.append(todoComponent)

        updateSections(activeTodos: activeTodos,
                       completedTodos: completedTodos,
                       animated: true)
    }

    private func closeAllSwipeMenus() {
        (activeTodos + completedTodos).forEach({ $0.offsetX = 0 })
    }
}

extension TodosViewModel {
    enum Constants {
        static var textFieldSectionId = "TextFieldSection"
        static var activeTodosSectionId = "ActiveTodosSection"
        static var completedTodosSectionId = "CompletedTodosSectionId"
    }
}
