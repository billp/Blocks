//
//  SampleViewController.swift
//  Blocks
//
//  Created by Vassilis Panagiotopoulos on 16/1/22.
//

import UIKit

class SampleViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.bounds = self.view.bounds

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
    }
}
