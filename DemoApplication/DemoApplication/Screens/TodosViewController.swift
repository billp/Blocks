//
//  TodoViewController.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

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
        TableViewRenderer(tableView: tableView)
    }

    private func registerComponents() {
        renderer.register(viewModelType: TodoTextFieldComponent.self, viewType: TodoTextFieldView.self)
        renderer.register(viewModelType: TodoListHeaderComponent.self, nibName: String(describing: TodoListHeaderView.self))
        renderer.register(viewModelType: EmptyResultsComponent.self, nibName: String(describing: EmptyResultsViewCell.self))
        renderer.register(viewModelType: TodoComponent.self, viewType: TodoView.self)
    }
}

