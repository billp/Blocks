<p></p>
<p align="center">
<img width="50%" alt="Logo" src="https://user-images.githubusercontent.com/1566052/155127115-829eb755-6d0f-4d2b-b6d0-b9adbc2c3a40.png">

</p>

<p align="center"><b>A Swift library for creating user interfaces using reusable components.
</b>
  
</p>

Blocks is a Swift library designed to simplify the creation of user interfaces in iOS applications. It allows developers to use both SwiftUI components and traditional UITableView cells, headers, and footers within the same UITableView. This approach facilitates a declarative way of building UIs while maintaining the flexibility to write custom code when necessary. Inspired by React, Blocks encourages the development of reusable components, promoting more abstract and modular code, which is especially beneficial for large and complex projects. The library leverages UIKit's UITableView as container to render components, and it supports the MVVM design pattern.

**The following video presents how UIKit, SwiftUI views are rendered in the same UITableView that acts as a container (renderer)** 

https://github.com/billp/Blocks/assets/1566052/67c5f322-3068-4513-82bd-965ce93b3b2a

# Installation
You can install **Blocks** using one of the following ways...
## CocoaPods

Add the following line to your **Podfile** and run **pod install** in your terminal:
```ruby
pod 'Blocks', '~> 0.1.0'
```

## Carthage

Add the following line to your **Carthage** and run **carthage update** in your terminal:
```ruby
github "billp/Blocks" ~> 0.1.0
```

## Swift Package Manager

Go to **File** > **Swift Packages** > **Add Package Dependency** and add the following URL :
```
https://github.com/billp/Blocks
```

# Table View Renderer

## Initialization

Create a new TableViewRenderer instance by passing an table view instance in its initializer.

```swift
// Create a lazy var for UITableView. You can also create the TableView in any way you want (Storyboard, Nib, etc.)
lazy var tableView: UITableView = {
    let tableView = UITableView()
    view.addSubview(tableView)
  
    tableView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: tableView.topAnchor),
        view.leftAnchor.constraint(equalTo: tableView.leftAnchor),
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        view.rightAnchor.constraint(equalTo: tableView.rightAnchor),
    ])

    return tableView
}()

// Create the Table View renderer and pass it a UITableView instance.
lazy var renderer = TableViewRenderer(tableView: tableView)
```

## Component Creation and Registration

Blocks enables the creation of flexible and reusable UI components by defining view models that conform to the `Component` protocol. These components can be rendered using various view types, including traditional nib files (for `UITableViewCell` and `UITableViewHeaderFooterView`), class-based views (for nibless initializations), or SwiftUI class types. This hybrid approach allows for the integration of both UIKit and SwiftUI elements within your application's UI, providing a versatile toolset for UI development.

### Traditional UIKit Component (Nib-based)

#### View Model:

Define a view model that conforms to the `Component` protocol.

```swift
struct EmptyResultsComponent: Component {
    var title: String
}
```

#### Cell View:

Implement a `UITableViewCell` subclass that conforms to `ComponentViewConfigurable` for configuring the cell with a view model.

```swift
class EmptyResultsViewCell: UITableViewCell, ComponentViewConfigurable {
    @IBOutlet weak var resultLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(with viewModel: any Component) {
        guard let component = viewModel.as(EmptyResultsComponent.self) else { return }
        resultLabel.text = component.title
    }
}
```

#### Xib File:

Associated xib file: `EmptyResultsViewCell.xib`.

#### Registration:

Register the component with the renderer to connect the view model with its corresponding view.

```swift
renderer.register(viewModelType: EmptyResultsComponent.self, nibName: String(describing: EmptyResultsViewCell.self))
```

This registration method applies similarly for headers and footers using nib files.

### SwiftUI Component

#### View Model:

Create a view model that conforms to the `Component` protocol, containing properties utilized by the SwiftUI view.

```swift
class TodoComponent: ObservableObject, Component {
    var id: UUID = .init()
    @Published var title: String

    init(title: String) {
       self.title = title
    }
}
```

#### View:

Construct a SwiftUI view that complies with `ComponentSwiftUIViewConfigurable`, using the view model for UI configuration.

```swift
import SwiftUI

struct TodoView: View, ComponentSwiftUIViewConfigurable {
    @ObservedObject private var viewModel: TodoComponent

    init(viewModel: any Component) {
        self.viewModel = viewModel.as(TodoComponent.self)
    }

    var body: some View {
        // SwiftUI view layout using viewModel properties
    }
}
```

#### Registration:

SwiftUI components are registered with the renderer to link the view model with its SwiftUI view, ensuring proper management and rendering within the UIKit-based table or collection view.

```swift
renderer.register(viewModelType: TodoComponent.self, viewType: TodoView.self)
```

This strategy for defining and registering components offers a modular and reusable approach for constructing your app's UI, leveraging the best of both UIKit and SwiftUI frameworks.

#### Usage

To update the UI using renderer.updateSections, incorporating TodoComponent with sample data and handling empty states with EmptyResultsComponent, you can follow this streamlined approach:

```swift
// Example method to update sections with todos and handle empty states
private func updateUI(withActiveTodos activeTodos: [TodoComponent], completedTodos: [TodoComponent]) {
    let activeSectionRows: [any Component] = activeTodos.isEmpty ? [EmptyResultsComponent(title: "No active todos.")] : activeTodos
    let completedSectionRows: [any Component] = completedTodos.isEmpty ? [EmptyResultsComponent(title: "No completed todos.")] : completedTodos
    
    let sections = [
        Section(id: "activeTodos", rows: activeSectionRows),
        Section(id: "completedTodos", rows: completedSectionRows)
    ]
    
    renderer.updateSections(sections, animation: .fade)
}

// Sample usage with active and completed todos
private func sampleUpdate() {
    let activeTodos = [
        TodoComponent(title: "Buy groceries"),
        TodoComponent(title: "Read a book")
    ]
    let completedTodos = [
        TodoComponent(title: "Workout"),
        TodoComponent(title: "Call mom")
    ]
    
    updateUI(withActiveTodos: activeTodos, completedTodos: completedTodos)
}
```

# Contributing to Blocks

We welcome contributions to Blocks! If you're looking to contribute, here's how you can help.

## How to Contribute

### Reporting Bugs

Before submitting a bug report, please check the issue tracker to avoid duplicates. When filing an issue, include:

- A clear and descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Screenshots (if applicable)

### Suggesting Enhancements

We love to hear about new features or improvements! For feature requests, please provide:

- A clear and concise description of what you want to happen
- Any additional context or screenshots about the feature request

### Pull Requests

Want to make a direct contribution? Great! Here's how:

1. Fork the repository and create your branch from `main`.
2. Write clear, commented code.
3. Ensure your changes pass any tests.
4. Update the README.md with details of changes, if applicable.
5. Submit a pull request with a comprehensive description of changes.

## Code of Conduct

Please note we have a Code of Conduct, please follow it in all your interactions with the project.

## Questions?

If you have any questions or need further clarification, feel free to open an issue or contact a project maintainer.

Thank you for your interest in contributing to Blocks! We look forward to your contributions.


# License
Blocks is available under the MIT license. See the LICENSE file for more info.
