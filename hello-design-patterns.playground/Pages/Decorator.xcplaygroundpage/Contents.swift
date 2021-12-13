//: [Previous](@previous)

/*:
 > [https://refactoring.guru/design-patterns/decorator](https://refactoring.guru/design-patterns/decorator)
 
 ![UML](Decorator.png)
 */

import UIKit
import CoreImage

protocol ImageEditor {
    func apply() -> UIImage
}

extension UIImage: ImageEditor {
    func apply() -> UIImage {
        return self
    }
}

class ImageDecorator: ImageEditor {
    var editor: ImageEditor
    
    required  init(editor: ImageEditor) {
        self.editor = editor
    }
    
    func apply() -> UIImage {
        return editor.apply()
    }
}

class BaseFilter: ImageDecorator {
    var filter: CIFilter?
    
    init(editor: ImageEditor, filterName: String) {
        self.filter = CIFilter(name: filterName)
        super.init(editor: editor)
    }
    
    required init(editor: ImageEditor) {
        super.init(editor: editor)
    }
    
    override func apply() -> UIImage {
        let image = super.apply()
        let context = CIContext(options: nil)
        
        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        
        guard let output = filter?.outputImage else { return image }
        guard let coreImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        return UIImage(cgImage: coreImage)
    }
}

class BlurFilter: BaseFilter {
    required init(editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIGaussianBlur")
    }
    
    func update(radius: Double) {
        filter?.setValue(radius, forKey: "inputRadius")
    }
}

class ColorFilter: BaseFilter {
    required init(editor: ImageEditor) {
        super.init(editor: editor, filterName: "CIColorControls")
    }
    
    func update(saturation: Double) {
        filter?.setValue(saturation, forKey: "inputSaturation")
    }
    
    func update(brightness: Double) {
        filter?.setValue(brightness, forKey: "inputBrightness")
    }
    
    func update(contrast: Double) {
        filter?.setValue(contrast, forKey: "inputContrast")
    }
}

class Resizer: ImageDecorator {
    private var xScale: CGFloat = 0
    private var yScale: CGFloat = 0
    private var hasAlpha = false
    
    convenience init(editor: ImageEditor, xScale: CGFloat = 0, yScale: CGFloat = 0, hasAlpha: Bool = false) {
        self.init(editor: editor)
        self.xScale = xScale
        self.yScale = yScale
        self.hasAlpha = hasAlpha
    }

    required init(editor: ImageEditor) {
        super.init(editor: editor)
    }
    
    override func apply() -> UIImage {
        let image = super.apply()
        
        let size = image.size.applying(CGAffineTransform(scaleX: xScale, y: yScale))
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? image
    }
}

// Application
let urlString = "https://refactoring.guru/images/content-public/logos/logo-new-3x.png"
let data = try? Data(contentsOf: URL(string: urlString)!)
let image = UIImage(data: data!)!
let resizer = Resizer(editor: image, xScale: 0.2, yScale: 0.2)

let blurFilter = BlurFilter(editor: resizer)
blurFilter.update(radius: 2)

let colorFilter = ColorFilter(editor: blurFilter)
colorFilter.update(contrast: 0.53)
colorFilter.update(brightness: 0.12)
colorFilter.update(saturation: 4)

let outputImage = colorFilter.apply()


//: [Next](@next)
