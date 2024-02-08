//
// TodoView.swift
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

struct TodoView: View, ComponentSwiftUIViewConfigurable {
    @ObservedObject private var viewModel: TodoComponent

    init(viewModel: any Component) {
        self.viewModel = viewModel.as(TodoComponent.self)
    }

    var body: some View {
        ZStack(alignment: .top) {
            swipeButtonsView
                .padding(TodoComponent.Constants.swipeMenuItemPadding / 2)
                .background(Color("TodoBackgroundColor"))
                .foregroundColor(tintColor)
                .clipShape(clipShape)
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
                .scaleEffect(viewModel.scale)

            HStack {
                leftIconView
                titleView
            }
            .frame(maxHeight: .infinity)
            .padding(15)
            .background(Color("TodoBackgroundColor"))
            .foregroundColor(tintColor)
            .overlay(clipShape.stroke(borderColor, lineWidth: 2))
            .clipShape(clipShape)
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
            .scaleEffect(viewModel.scale)
            .offset(.init(width: viewModel.offsetX, height: 0))
            .animation(.spring(duration: 0.25), value: viewModel.offsetX)
            .gesture(dragGesture)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.3)) {
                viewModel.scale = 1.0
            }
        }

    }
}

extension TodoView {
    var tintColor: Color {
        Color(viewModel.completed ? 
                "TodoCompletedTintColor" :
                "TodoActiveTintColor")
    }

    var borderColor: Color {
        Color(viewModel.completed ?
                "TodoCompletedBorderColor" :
                "TodoActiveBorderColor")
    }

    var leftIconView: some View {
        let systemName = viewModel.completed ? 
            "checkmark.circle" :
            "circle"
        return Image(systemName: systemName)
            .onTapGesture(perform: viewModel.toggleCompleted)
    }

    var clipShape: some Shape {
        RoundedRectangle(cornerRadius: 5)
    }

    var titleView: some View {
        Text(viewModel.title)
            .font(.footnote)
            .bold()
            .strikethrough(viewModel.completed)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var swipeButtonsView: some View {
        HStack {
            Spacer()
            Button(action: { 
                viewModel.offsetX = 0
                viewModel.deleteAction()
            }) {
                Image(systemName: "trash.square.fill")
                    .resizable()
                    .foregroundColor(Color.red)
                    .frame(width: TodoComponent.Constants.swipeMenuItemWidth,
                           height: TodoComponent.Constants.swipeMenuItemWidth)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
        return DragGesture(minimumDistance: 30)
            .onChanged(viewModel.dragGestureOnChange)
            .onEnded(viewModel.dragGestureEnded)
    }
}


#Preview {
    TodoView(viewModel: TodoComponent(todo: .init(title: "Line1\nLine2",
                                                  completed: false)))
        .frame(height: 80)
}
