//
//  UIImage+ScaleImage.swift
//  LambdaTimeline
//
//  Created by Ilgar Ilyasov on 11/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

// 7. ScaleImage added

extension UIImage {
    
    class func scaleImage(image: UIImage, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}
