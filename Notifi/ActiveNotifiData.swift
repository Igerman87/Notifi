//
//  ActiveNotifiData.swift
//  Notifi
//
//  Created by ilya_admin on 05/01/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

struct ActiveNotifiData : Codable{
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case phoneNumber
        case phoneType
        case time
        case picture
        case indetifier
    }

    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let picture = picture, let data = picture.pngData() {
            try container.encode(data, forKey: .picture)
        }
        
        try container.encode(fullName, forKey: .fullName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(phoneType, forKey: .phoneType)
        try container.encode(time, forKey: .time)
        try container.encode(indetifier, forKey: .indetifier)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try container.decode(String.self, forKey: .fullName)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        phoneType = try container.decode(String.self, forKey: .phoneType)
        time = try container.decode(String.self, forKey: .time)

        indetifier = try container.decode(String.self, forKey: .indetifier)
        
        if let text = try container.decodeIfPresent(String.self, forKey: .picture) {
            if let data = Data(base64Encoded: text) {
                picture = UIImage(data: data)
            }
        }

    }
    
    
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

