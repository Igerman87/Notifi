//
//  ActiveNotifiDataTable.swift
//  Notifi
//
//  Created by ilya_admin on 08/01/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class ActiveNotifiDataTableCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    func Update(number: String, name: String) -> Void
    {
        nameLabel.text = name
        numberLabel.text = number
    }
}
