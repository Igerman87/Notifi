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
    @IBOutlet weak var date: UILabel!
    
    var cellFullInfo:ActiveNotifiData!
    
    func update(activeStruct: ActiveNotifiData) {
        
        cellFullInfo = activeStruct
        
        name.text = activeStruct.fullName
        type.text = activeStruct.phoneType
        picture.image = activeStruct.picture
        date.textColor = UIColor(displayP3Red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1)
        date.text = setDateField(stringDate: String(activeStruct.time.prefix(10)))
        
        let nofitiContact = contactsOneDimantion.filter {$0.FullName == name.text}
        
        // only if the contact has a picture add it else use unknown
        if nofitiContact.isEmpty == false
        {
            picture.image = nofitiContact[0].Picture
            cellFullInfo.picture = picture.image
        }
    }
    
    func setDateField(stringDate: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: stringDate)
        let now = Date()
        
        if Calendar.current.isDateInToday(date!)
        {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(date!)
        {
            return "Yesterday"
        }
        if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .weekOfYear)
        {
            return "This\rWeek"
        }
        else if Calendar.current.isDate(now.addingTimeInterval(TimeInterval(-nextWeek)), equalTo: date!, toGranularity:  .weekOfYear)
        {
            return "Last\rWeek"
        }
        else if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .month)
        {
            return "This\rMonth"
        }
        else if Calendar.current.isDate(now.addingTimeInterval(TimeInterval(-nextMonth)), equalTo: date!, toGranularity:  .month)
        {
            return "Last\rMonth"
        }
        else if Calendar.current.isDate(now, equalTo: date!, toGranularity:  .year)
        {
            return "This\rYear"
        }
        else
        {
            return "This Millennium"
        }
    }
}
