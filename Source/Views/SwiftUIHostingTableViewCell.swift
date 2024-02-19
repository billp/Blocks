// SwiftUIHostingTableViewCell.swift
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

import UIKit
import SwiftUI

class SwiftUIHostingTableViewCell: UITableViewCell, ComponentViewConfigurable {
    weak var hostingController: UIHostingController<AnyView>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.listPlainHeaderFooter()
            backgroundConfig.backgroundColor = .clear
            backgroundConfiguration = backgroundConfig
        } else {
            backgroundColor = .clear
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: any Component) {
        guard let swiftUIView = try? renderer?.swiftUIView(for: viewModel) else {
            fatalError("\(type(of: viewModel)) is not registered")
        }

        if #available(iOS 16.0, *) {
            configureForiOS16(with: AnyView(swiftUIView))
        } else {
            configureForEarlieriOS(with: AnyView(swiftUIView))
        }
    }

    @available(iOS 16.0, *)
    private func configureForiOS16(with view: AnyView) {
        self.contentConfiguration = UIHostingConfiguration {
            view
        }
        .margins(.all, 0)
    }

    private func configureForEarlieriOS(with view: AnyView) {
        var hostingController: UIHostingController<AnyView>!
        if let hControler = self.hostingController {
            hostingController = hControler
        } else {
            hostingController = UIHostingController(rootView: view)
        }

        self.hostingController = hostingController
        setupHostingControllerView(hostingController.view)
    }

    private func setupHostingControllerView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
