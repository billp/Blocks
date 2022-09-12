<p></p>
<p align="center">
<img width="50%" alt="Logo" src="https://user-images.githubusercontent.com/1566052/155127115-829eb755-6d0f-4d2b-b6d0-b9adbc2c3a40.png">

</p>

<p align="center"><b>A Swift library for creating user interfaces using reusable components.
</b>
  
</p>

Blocks is the only library you need to create user interfaces in a declerative way whilst at the same time keeping the flexibility of writing custom code when needed. It saves time on writing boilerplate code by focusing more on the actual UI & Animations and less on how to render your views. Inspired by React, it enforces you to create reusable components that leads to writing more abstract and modular code, recommended in large and complex projects. Blocks utilizes UIKit's **UITableView** and **UICollectionView** as containers to render components, leveraging the **MVVM design pattern**.

# Installation
You can install **Blocks** using one of the following ways...
## CocoaPods

Add the following line to your **Podfile** and run **pod install** in your terminal:
```ruby
pod 'Blocks', '~> 1.0.0'
```

## Carthage

Add the following line to your **Carthage** and run **carthage update** in your terminal:
```ruby
github "billp/Blocks" ~> 1.0.0
```

## Swift Package Manager

Go to **File** > **Swift Packages** > **Add Package Dependency** and add the following URL :
```
https://github.com/billp/Blocks
```

# Table View Renderer

## Initialization

Create a new TableViewRenderer instance by passing an table view instance in its initializer.

```swift
// Create a lazy var for UITableView. You can also create the TableView in any way you want (Storyboard, Nib, etc.)
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

// Create the Table View renderer and pass it a UITableView instance.
lazy var renderer = TableViewRenderer(tableView: tableView)
```

## Render Components

You can use the renderer's **setSection** method to build your sections. Each section consists of a header (optional), a footer (optional) and row components, which you can define by implementing one of the following protocols:
- **NibComponent** for nib based components.
- **ClassComponent** for nibless components.

### Example

See the definition of components **[here](/Components.md)**.

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

If you run the code above you will see the following screen in simulator:

<p>
  <img width="350px" alt="Renderer in Action" src="https://user-images.githubusercontent.com/1566052/155484594-2bc1178d-382d-432f-942a-526b0ca60ded.png">
</p>

