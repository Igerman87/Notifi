//
//  ActiveNotifiCell.swift
//  Notifi
//
//  Created by ilya_admin on 13/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

let nextWeek = 604800
let nextMonth = 2678400

class ActiveNotifiCell: UITableViewCell {
    
    @IBOutlet weak var ActiveNotifiLabel: UILabel!
    @IBOutlet weak var ActiveNotifiPhoneTypeLongNameForAll: UILabel!
    @IBOutlet weak var ActiveNotifiTime: UILabel!
    @IBOutlet weak var ActiveNotifiPicture: UIImageView!
    
    var cellFullInfo: ActiveNotifiData!
    
    func Update(activeNotifi: ActiveNotifiData) -> Void
    {
        cellFullInfo = activeNotifi
        
        ActiveNotifiTime.textColor = UIColor(displayP3Red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1)
        
        
        ActiveNotifiLabel.text = activeNotifi.fullName
        ActiveNotifiPhoneTypeLongNameForAll.text = activeNotifi.phoneType
        ActiveNotifiTime.text = setDateField(stringDate: activeNotifi.time)
        ActiveNotifiPicture.image = activeNotifi.picture
    }
    
    func setDateField(stringDate: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        let date = dateFormatter.date(from: stringDate)
        let now = Date()
        
        if Calendar.current.isDateInToday(date!) == false && Calendar.current.isDateInTomorrow(date!) == false
        {
            if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .weekOfYear)
            {
                return "This\rWeek"
            }
            else if Calendar.current.isDate(now.addingTimeInterval(TimeInterval(nextWeek)), equalTo: date!, toGranularity:  .weekOfYear)
            {
                return "Next\rWeek"
            }
            else if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .month)
            {
                return "This\rMonth"
            }
            else if Calendar.current.isDate(now.addingTimeInterval(TimeInterval(nextMonth)), equalTo: date!, toGranularity:  .month)
            {
                return "Next\rMonth"
            }
            else if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .year)
            {
                return "This\rYear"
            }
            else
            {
                return "Far\rFuture"
            }
        }
        else
        {
            let start = stringDate.index(stringDate.startIndex, offsetBy: 11)
            let end = stringDate.index(stringDate.startIndex, offsetBy: 16)
            
            let range = start..<end
            return String(stringDate[range])
        }
    }
}
