//
//  ImageData.swift
//  Locker
//
//  Created by wahid tariq on 30/10/21.
//

import Foundation
import UIKit

class ImageData: NSObject, Codable {
 
    var image: String
     
    init(image: String){
        self.image = image
    }
    
//    required init?(coder: NSCoder) {
//       image = coder.decodeObject(forKey: "image") as? String ?? ""
//
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(image, forKey: "image")
//    }
   
}
