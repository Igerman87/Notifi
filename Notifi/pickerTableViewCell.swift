//
//  pickerTableViewCell.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class pickerTableViewCell: UITableViewCell
{
    
    class var expendedHeight: CGFloat{get {return 350}}
    class var defaultHeight: CGFloat{get {return 44}}
    
    var cellContactDetails: NotifiContact!
    var cellReminderPhoneNumber: String!
    
    var isObserving = false
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    @IBOutlet weak var addNotifiOutlet: UIButton!
    
    @IBOutlet weak var reminderPicker: UIDatePicker!
    
    @IBAction func addNotifi(_ sender: Any)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        if reminderPicker.date > Date()
        {
            let myNotifi = myNotifications()
            
            let timeString = dateFormatter.string(from: reminderPicker.date)
            
            let time = dateFormatter.date(from: timeString)
            
            cellContactDetails.ReminderPhoneNumber = cellReminderPhoneNumber
            
            myNotifi.createNotification(contact: cellContactDetails, Time: time!)
            //nofiti.setReminder(contact: cellContactDetails, time: reminderPicker.date)
        }
        else
        {
            reminderPicker.date = Date(timeIntervalSinceNow: 120)
        }
    }
    
    
    func checkHeight()
    {
        if (frame.size.height < pickerTableViewCell.expendedHeight)
        {
            titlelabel.font = UIFont.systemFont(ofSize: 17.0)
            addNotifiOutlet.isEnabled = false
        }
        else
        {
            titlelabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            addNotifiOutlet.isEnabled = true
        }
    }
    
    func Update(CellContact: NotifiContact)
    {
        
        cellReminderPhoneNumber = ((CellContact.PhoneNumbers[0].value).value(forKey: "digits") as! String)

        cellContactDetails = CellContact
        cellContactDetails.ReminderPhoneNumber = cellReminderPhoneNumber

        //reminderPicker.minuteInterval = 5
        reminderPicker.datePickerMode = UIDatePicker.Mode.dateAndTime

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        reminderPicker.date = Date(timeIntervalSinceNow: 60 * 60)
        
        self.reminderPicker.addTarget(self, action: #selector(reminderPickerDateChanged), for: .valueChanged)

        PhoneNumberLabel.text = cellReminderPhoneNumber
   
    }
    
    @objc func reminderPickerDateChanged(reminderPicker: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if reminderPicker.date < Date()
        {
            reminderPicker.date = Date(timeIntervalSinceNow: 120)
        }
    }
        


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
