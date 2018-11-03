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
    
    func Update(fullName:String) -> Void {
        
       nameLabel.text = fullName
    }
}
