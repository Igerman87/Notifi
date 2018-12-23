//
//  nameCell.swift
//  Notifi
//
//  Created by ilya_admin on 01/11/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class NameCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    
    func Update(CellContact: NotifiContact) -> Void {
        
        nameLabel.text = CellContact.FullName
        contactImage.image = CellContact.Picture
    }
}
