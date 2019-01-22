//
//  ActiveNotifiData.swift
//  Notifi
//
//  Created by ilya_admin on 05/01/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class ActiveNotifiData : NSObject {
    
    var fullName: String!
    var phoneNumber: String!
    var phoneType: String!
    var time: String!
    var picture:  UIImage!
    
    var indetifier: String!
    
    init(fullnameIn: String, phoneNumberIn: String, phoneTypeIn: String, timeIn: String, pictureIn: UIImage, indetifierIn: String)
    {
        fullName = fullnameIn
        phoneNumber = phoneNumberIn
        phoneType = phoneTypeIn
        time = timeIn
        picture = pictureIn
        
        indetifier = indetifierIn

    }
    

}

