//
//  TestFieldWrapper.swift
//  DemoApplication
//
//  Created by Bill Panagiotopoulos on 15/2/24.
//

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
