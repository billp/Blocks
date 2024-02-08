//
//  TodoViewViewModel.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 14/2/24.
//

import Foundation
import Blocks
import Combine

class TodosViewModel {
    // MARK: - Properties

    private weak var renderer: TableViewRenderer?
    private var activeTodos: [TodoComponent] = []
    private var disposableBag = Set<AnyCancellable>()
    private var completedTodos: [TodoComponent] = []
    private var todoInputField = TodoTextFieldComponent(
        placeholder: NSLocalizedString("What's next?", comment: "")
    )

    // MARK: - Initializers

    init(with renderer: TableViewRenderer) {
        self.renderer = renderer
        setupTextFieldBindings()
    }

    // MARK: - Lifecycle

    func configureScreen() {
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
        todoInputField.value = ""

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

    private func updateSections(activeTodos: [TodoComponent],
                                completedTodos: [TodoComponent],
                                animated: Bool = false) {
        self.activeTodos = activeTodos
        self.completedTodos = completedTodos

        let newSections = [
            Section(
                id: Constants.textFieldSectionId,
                rows: [todoInputField, Spacer(type: .fixed(15))]
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

        renderer?.updateSections(newSections, animation: animated ? .automatic : .none)
    }

    private func createActiveTodos(_ todos: [TodoComponent]) -> [any Component] {
        if todos.isEmpty {
            return [EmptyResultsComponent(title: "No active todos.")]
        }

        return todos + [Spacer(type: .fixed(15))]
    }

    private func createCompletedTodos(_ todos: [TodoComponent]) -> [any Component] {
        if todos.isEmpty {
            return [EmptyResultsComponent(title: "No completed todos.")]
        }

        return todos
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
}

extension TodosViewModel {
    enum Constants {
        static var textFieldSectionId = "TextFieldSection"
        static var activeTodosSectionId = "ActiveTodosSection"
        static var completedTodosSectionId = "CompletedTodosSectionId"
    }
}
