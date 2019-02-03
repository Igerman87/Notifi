//
//  randomCollectionCell.swift
//  Notifi
//
//  Created by ilya_admin on 20/01/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class randomCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var someShitImage: UIImageView!
    @IBOutlet weak var someShitName: UILabel!
    @IBOutlet weak var someShitType: UILabel!
    
    func update(data: ActiveNotifiData) {
        
        someShitName.text = data.fullName.components(separatedBy: " ").first
        someShitImage.image = data.picture
        someShitType.text = data.phoneType
    }
}
