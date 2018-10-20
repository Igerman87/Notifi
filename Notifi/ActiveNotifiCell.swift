//
//  ActiveNotifiCell.swift
//  Notifi
//
//  Created by ilya_admin on 13/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class ActiveNotifiCell: UITableViewCell {
    
    @IBOutlet weak var ActiveNotifiLabel: UILabel!
    
    func Update(time:String) -> Void {
        
        ActiveNotifiLabel.text = time
    }
}
