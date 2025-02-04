# TemplateEditor

[![CI Status](https://img.shields.io/travis/talaakash/TemplateEditor.svg?style=flat)](https://travis-ci.org/talaakash/TemplateEditor)
[![Version](https://img.shields.io/cocoapods/v/TemplateEditor.svg?style=flat)](https://cocoapods.org/pods/TemplateEditor)
[![License](https://img.shields.io/cocoapods/l/TemplateEditor.svg?style=flat)](https://cocoapods.org/pods/TemplateEditor)
[![Platform](https://img.shields.io/cocoapods/p/TemplateEditor.svg?style=flat)](https://cocoapods.org/pods/TemplateEditor)

## Example
In your project just import this pod and from controller you open editing screen just write code beloew
```ruby
EditController.featureDelegate = self
EditController.userDelegate = self
EditController.exportDelegate = self
let editor = EditController()
editor.showEditor(from: self.navigationController!)
```
One more thing you have to handle delegate method of it for customised options

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TemplateEditor is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TemplateEditor'
```

## Author

Tala Akash, akasht.noble@gmail.com

## License

TemplateEditor is available under the MIT license. See the LICENSE file for more info.
