//
//  randomViewController.swift
//  Notifi
//
//  Created by ilya_admin on 23/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class randomViewController: UIViewController, UITextFieldDelegate
{
    var datePicker:UIDatePicker = UIDatePicker()

    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    
    @IBAction func setNotifiRandom(_ sender: Any)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"

        
        if phoneText.text != nil
        {
            if datePicker.date > Date()
            {
                let myNotifi = myNotifications()
                let contact = NotifiContact(fullName: nameText.text!, phoneNumbers: CNLabeledValue, emails: nil, reminderPhone: phoneText.text)
                
                let time = dateFormatter.date(from: timeText.text!)
                
                myNotifi.createNotification(contact: <#T##NotifiContact#>, time: <#T##Date#>)
                
                contact.ReminderPhoneNumber = phoneText.text!
                
                myNotifi.createNotification(contact: contact, time: time!)
                //nofiti.setReminder(contact: cellContactDetails, time: reminderPicker.date)
            }
            else
            {
                datePicker.date = Date()
            }
        }
    }
    override func viewDidLoad()
    {
        if UIPasteboard.general.string != nil
        {
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: UIPasteboard.general.string!))
            {
                phoneText.text = UIPasteboard.general.string
            }
        }
        
        datePicker.datePickerMode = .time
        
        phoneText.delegate = self
        phoneText.keyboardType = UIKeyboardType.numberPad
        nameText.delegate = self
        timeText.delegate = self
        
        timeText.inputView = datePicker
    
    }

}
