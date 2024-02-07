//
//  ViewController.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 7/2/24.
//

import UIKit
import Blocks

class ViewController: UIViewController {

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

    lazy var renderer = TableViewRenderer(tableView: tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        renderer.updateSections([
            Section(id: "section1",
                    header: MyHeaderFooterComponent(title: "Header 1").asBlock,
                    footer: MyHeaderFooterComponent(title: "Footer 1").asBlock,
                    items: [
                        MyLabelComponent(title: "Row 1"),
                        MyLabelComponent(title: "Row 2"),
                        MyLabelComponent(title: "Row 3"),
                        MyButtonComponent(title: "Button 1", onTap: {
                            print("Button 1 tapped")
                        })
                    ].asBlocks),
            Section(id: "section2",
                    header: MyHeaderFooterComponent(title: "Header 2").asBlock,
                    footer: MyHeaderFooterComponent(title: "Footer 2").asBlock,
                    items: [
                        MyLabelComponent(title: "Row 4"),
                        MyLabelComponent(title: "Row 5"),
                        MyLabelComponent(title: "Row 6"),
                        MyButtonComponent(title: "Button 2", onTap: {
                            print("Button 2 tapped")
                        })
                    ].asBlocks)
        ], animation: .none)
    }
}

