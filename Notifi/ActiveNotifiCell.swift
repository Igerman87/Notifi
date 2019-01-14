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
    @IBOutlet weak var ActiveNotifiPhoneTypeLongNameForAll: UILabel!
    @IBOutlet weak var ActiveNotifiTime: UILabel!
    @IBOutlet weak var ActiveNotifiPicture: UIImageView!
    
    func Update(activeNotifi: ActiveNotifiData) -> Void
    {
        let start = activeNotifi.time.index(activeNotifi.time.startIndex, offsetBy: 11)
        let end = activeNotifi.time.index(activeNotifi.time.startIndex, offsetBy: 16)
        let range = start..<end
        let subStr = activeNotifi.time[range]
        
        ActiveNotifiTime.textColor = UIColor(displayP3Red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1)
        
        
        ActiveNotifiLabel.text = activeNotifi.fullName
        ActiveNotifiPhoneTypeLongNameForAll.text = activeNotifi.phoneType
        ActiveNotifiTime.text = String(subStr)
        ActiveNotifiPicture.image = activeNotifi.picture
    }
}
