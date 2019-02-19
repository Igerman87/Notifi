//
//  HistoryCell.swift
//  Notifi
//
//  Created by ilya_admin on 19/02/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation

import UIKit


class historyCell: UITableViewCell {


    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    var cellFullInfo:ActiveNotifiData!
    
    func update(activeStruct: ActiveNotifiData) {
        
        cellFullInfo = activeStruct
        
        name.text = activeStruct.fullName
        type.text = activeStruct.phoneType
        picture.image = activeStruct.picture
        
        let nofitiContact = contactsOneDimantion.filter {$0.FullName == name.text}
        
        if nofitiContact.isEmpty == false
        {
            picture.image = nofitiContact[0].Picture
            cellFullInfo.picture = picture.image
        }
    }
}
