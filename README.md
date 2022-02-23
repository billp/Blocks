<p></p>
<p align="center">
<img width="50%" alt="Logo" src="https://user-images.githubusercontent.com/1566052/155127115-829eb755-6d0f-4d2b-b6d0-b9adbc2c3a40.png">

</p>

<p align="center"><b>A Swift library for creating user interfaces using reusable components.
</b>
  
</p>

Blocks is the only library you need to create user interfaces without loosing the flexibility of writing custom code whenever needed. It saves you time on writing boilerplate code by focusing more on the actual UI & Animations and less on how to render your views. Inspired by React, it enforces you to create reusable components which leads to writing more abstract and modular code, required in large and complex projects. Blocks utilizes UIKit's **UITableView** and **UICollectionView** as containers to render the components, leveraging the **MVVM design pattern**.

## Renderer In action

<p>
  <img width="350px" alt="Renderer in Action" src="https://user-images.githubusercontent.com/1566052/155356991-63343f74-4ee7-42f4-a2b2-fe1447f21345.png">
</p>

The screen above shows how the components are rendered with the following code:

```swift
renderer.setSections([
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
```
