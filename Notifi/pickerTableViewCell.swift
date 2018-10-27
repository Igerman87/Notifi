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
    @IBOutlet weak var phoneButtonOutlet: UIButton!
    @IBOutlet weak var reminderTimeSelect: UILabel!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    @IBOutlet weak var addNotifiOutlet: UIButton!
    
    @IBOutlet weak var reminderPicker: UIDatePicker!
    
    @IBAction func phoneButton(_ sender: Any)
    {
        // To be added
    }
    
    @IBAction func addNotifi(_ sender: Any)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        if reminderPicker.date > Date()
        {
            let myNotifi = myNotifications()
            
            let time = dateFormatter.date(from: reminderTimeLabel.text!)
            
            cellContactDetails.ReminderPhoneNumber = cellReminderPhoneNumber
            
            myNotifi.createNotification(contact: cellContactDetails, time: time!)
            //nofiti.setReminder(contact: cellContactDetails, time: reminderPicker.date)
        }
        else
        {
            reminderPicker.date = Date()
            
            
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
    
    func watchFrameChages()
    {
        if !isObserving
        {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: nil)
            checkHeight()
            
            isObserving = true
        }
    }
    
    func ignoreFrameChanges()
    {
        if isObserving
        {
            removeObserver(self, forKeyPath:"frame")
            isObserving = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "frame"
        {
            checkHeight()  
        }
    }
    
    func Update(CellContact: NotifiContact)
    {
        cellReminderPhoneNumber = ((CellContact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
        
        cellContactDetails = CellContact
        cellContactDetails.ReminderPhoneNumber = cellReminderPhoneNumber
        
        titlelabel.text = CellContact.FullName
        //reminderPicker.minuteInterval = 5
        reminderPicker.datePickerMode = UIDatePicker.Mode.dateAndTime

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        reminderTimeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSinceNow: (60 * 60)))
        
        reminderPicker.date = Date(timeIntervalSinceNow: 60 * 60)
        
        self.reminderPicker.addTarget(self, action: #selector(reminderPickerDateChanged), for: .valueChanged)

        PhoneNumberLabel.text = "Number: " + cellReminderPhoneNumber
        if CellContact.PhoneNumbers.count == 1
        {
            phoneButtonOutlet.isEnabled = false
        }
        else
        {
            phoneButtonOutlet.isEnabled = true
        }
    }
    
    @objc func reminderPickerDateChanged(reminderPicker: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if reminderPicker.date < Date()
        {
            reminderPicker.date = Date()
        }
        else
        {
            reminderTimeLabel.text = dateFormatter.string(from: reminderPicker.date)
        }
    }
        


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
