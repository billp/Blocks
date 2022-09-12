# MyHeaderFooterComponent

## ViewModel
```swift
struct MyHeaderFooterComponent: ClassComponent {
    var title: String

    var viewClass: AnyClass {
        MyHeaderFooterView.self
    }
}
```

## View

```swift
class MyHeaderFooterView: UITableViewHeaderFooterView {
    var label: UILabel!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addUIElements()
    }

    private func addUIElements() {
        label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .blue

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension MyHeaderFooterView: ComponentViewConfigurable {
    func configure(with model: Block) {
        let model = model.as(MyHeaderFooterComponent.self)
        label.text = model.title
    }
}
```


# MyLabelComponent

## ViewModel

```swift
struct MyLabelComponent: ClassComponent {
    var title: String

    var viewClass: AnyClass {
        LabelViewCell.self
    }
}
```

## View

```swift
class LabelViewCell: UITableViewCell, ComponentViewConfigurable {
    func configure(with model: Block) {
        let model = model.as(MyLabelComponent.self)
        textLabel?.text = model.title
        selectionStyle = .none
    }
}
```

# MyButtonComponent

## ViewModel

```swift
struct MyButtonComponent: ClassComponent {
    var title: String
    var onTap: (() -> Void)?

    var viewClass: AnyClass {
        ButtonViewCell.self
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: MyButtonComponent, rhs: MyButtonComponent) -> Bool {
        lhs.title == rhs.title
    }
}
```

## View

```swift
class ButtonViewCell: UITableViewCell, ComponentViewConfigurable {
    var model: MyButtonComponent!
    var button: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        addUIElements()
    }

    private func addUIElements() {
        button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        let padding: CGFloat = 10

        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: padding),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -padding),
        ])
    }

    @objc func buttonAction() {
        model.onTap?()
    }

    func configure(with model: Block) {
        let model = model.as(MyButtonComponent.self)
        button.setTitle(model.title, for: .normal)

        self.model = model

    }
}
```
