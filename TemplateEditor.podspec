#
# Be sure to run `pod lib lint TemplateEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TemplateEditor'
    s.version          = '1.1.5'
    s.summary          = 'A TemplateEditor pod is very useful for developer that want to create app which generate templates so this can make there work hassle free.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    TemplateEditor is a flexible and customizable iOS framework that allows developers to integrate a powerful template editor into their apps. With TemplateEditor, users can create, edit, and customize various templates by adding and adjusting images, text, and other UI elements in real-time. It supports a wide range of template styles and offers easy integration into existing projects.
    
    The library includes features such as drag-and-drop functionality, interactive design components, and live preview, making it ideal for apps that require customizable templates such as menu creators, design tools, and other creative applications.
    
    TemplateEditor is designed to be lightweight, intuitive, and extensible, allowing for seamless integration with other libraries and providing full control over the UI components for customization. The framework comes with built-in support for handling image assets, dynamic text elements, and other components, ensuring that your app can handle complex template editing workflows with ease.
    
    Key Features:
    - Drag-and-drop interface for adding images, text, and elements.
    - Support for various template styles with customizable layouts.
    - Intuitive UI for real-time template editing.
    - Easy integration with existing projects.
    - Extensible and customizable components.
    - Built-in image handling and dynamic text support.
    
    This pod is perfect for developers who need a template editing solution within their iOS apps, providing all the tools necessary to create a personalized and interactive design experience for their users.
    
    DESC
    
    s.homepage         = 'https://github.com/talaakash/TemplateEditor'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'talaakash' => 'akasht.noble@gmail.com' }
    s.source           = { :git => 'https://github.com/talaakash/TemplateEditor.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '15.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/**/*.{swift,xib,storyboard}'
    
    s.resources = [
    "Sources/**/*.xcassets"
    ]
    
    s.frameworks = 'UIKit'
    s.dependency 'Kingfisher'
    s.resource_bundles = {
      'Views' => ['Sources/Views/*.{swift, Xib}'],
      'Resources' => ['Sources/Resources/*.{xcassets, swift}'],
      'HelperClass' => ['Sources/HelperClass/*.swift'],
      'Libraries' => ['Sources/Libraries/**/*.{swift, xib}'],
      'Xibs' => ['Sources/Xibs/**/*.{swift, xib}'],
      'CustomViews' => ['Sources/CustomViews/*.swift'],
      'Menues' => ['Sources/Menues/**/*.{swift, xib}'],
      'Models' => ['Sources/Models/*.swift'],
      'StoryBoard' => ['Sources/StoryBoard/*.storyboard'],
      'Controllers' => ['Sources/Controllers/*.swift', 'Sources/Controllers/**/*.swift'],
      'Extensions' => ['Sources/Extensions/*.swift'],
      'TemplateEditor' => ['Sources/*.swift'],
    }
end
