// TestFieldWrapper.swift
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
import SwiftUI

struct TestFieldWrapper: UIViewRepresentable {
    @Binding var text: String

    var placeholder: String
    var onReturn: (() -> Void)?

    init(_ placeholder: String, 
         text: Binding<String>,
         onReturn: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onReturn = onReturn
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.textColor = UIColor(named: "TodoActiveTintColor")
        textField.font = .boldSystemFont(ofSize: 18)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        private var parent: TestFieldWrapper

        init(_ textField: TestFieldWrapper) {
            self.parent = textField
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let currentText = textField.text, let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: string)
                DispatchQueue.main.async { [weak self] in
                    self?.parent.text = updatedText
                }
            }

            return true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onReturn?()
            textField.resignFirstResponder()
            return true
        }
    }
}
