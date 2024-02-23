// TodoTextFieldView.swift
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

import SwiftUI
import Blocks

struct TodoTextFieldView: View, ComponentSwiftUIViewConfigurable {
    @ObservedObject var viewModel: TodoTextFieldComponent

    init(viewModel: any Component) {
        self.viewModel = viewModel.as(TodoTextFieldComponent.self)
    }

    var body: some View {
        HStack {
            TextFieldWrapper(viewModel.placeholder, 
                             text: $viewModel.value) {
                viewModel.onReturnPublisher.send(viewModel.value)
            }
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color("TodoActiveTintColor")),
                alignment: .bottom
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 5)
        .background(Color("TodoTextFieldBgColor"))
        .scaleEffect(viewModel.scale)
        .opacity(viewModel.scale)
        .onAppear {
            withAnimation(.spring(duration: 0.3)) {
                viewModel.scale = 1.0
            }
        }
    }
}

#Preview {
    let viewModel = TodoTextFieldComponent(placeholder: "My todo...")
    return TodoTextFieldView(viewModel: viewModel)
        .frame(minHeight: 0, maxHeight: .leastNonzeroMagnitude)

}
