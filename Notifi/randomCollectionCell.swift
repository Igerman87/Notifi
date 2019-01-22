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
    
    func update(data: NotifiContact) {
        
        someShitName.text = data.FullName
        someShitImage.image = data.Picture
    }
}
