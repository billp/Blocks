// TodosViewController.swift
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

import UIKit
import Blocks
import SwiftUI

class TodosViewController: UIViewController {

    private lazy var viewModel: TodosViewModel = .init(with: renderer)
    private lazy var tableView: UITableView = createTableView()

    lazy var renderer = createRenderer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Todos", comment: "")
        self.navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "plus.rectangle.fill.on.rectangle.fill"),
                                                       style: .plain,
                                                       target: self, action: #selector(self.shuffleAction))

        registerComponents()
        viewModel.configureScreen()
    }

    @objc func shuffleAction() {
        viewModel.addSamples()
    }

    private func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = true

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            view.rightAnchor.constraint(equalTo: tableView.rightAnchor),
        ])

        return tableView
    }

    private func createRenderer() -> TableViewRenderer {
        let renderer = TableViewRenderer(tableView: tableView)
        renderer.dragEnabled = true
        return renderer
    }

    private func registerComponents() {
        renderer.register(viewModelType: TodoTextFieldComponent.self, viewType: TodoTextFieldView.self)
        renderer.register(viewModelType: TodoListHeaderComponent.self, nibName: String(describing: TodoListHeaderView.self))
        renderer.register(viewModelType: EmptyResultsComponent.self, nibName: String(describing: EmptyResultsViewCell.self))
        renderer.register(viewModelType: TodoComponent.self, viewType: TodoView.self)
    }
}

