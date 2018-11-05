//
//  randomViewController.swift
//  Notifi
//
//  Created by ilya_admin on 23/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications // debug

class randomViewController: UIViewController, UITextFieldDelegate
{
    var datePicker:UIDatePicker = UIDatePicker()

    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    
    @IBAction func buttonSetNotifi(_ sender: UIButton)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"

        view.endEditing(true)
        
        if phoneText.text != ""
        {
            if datePicker.date > Date()
            {
                let myNot = myNotifications()
                
                myNot.createNotification(FullName: nameText.text == "" ? "John Doe": nameText.text!,
                                        ReminderPhoneNumber: phoneText.text!, Time:datePicker.date, Alert: true)
            }
            else
            {
                let dateFormatterWithoutSeconds = DateFormatter()
                dateFormatterWithoutSeconds.dateFormat = "yyyy-MM-dd HH:mm"
                
                datePicker.date = Date(timeIntervalSinceNow: 120)
                
                timeText.text = dateFormatterWithoutSeconds.string(from: datePicker.date)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Notifi issue", message: "Phone number must be entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        checkClipBoard()
    }

    override func viewDidLoad()
    {
        datePicker.datePickerMode = .dateAndTime
        self.datePicker.addTarget(self, action: #selector(reminderPickerDateChanged), for: .valueChanged)
        
        phoneText.delegate = self
        phoneText.keyboardType = UIKeyboardType.phonePad
        nameText.delegate = self
        timeText.delegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        timeText.inputView = datePicker
        timeText.text = dateFormatter.string(from: Date(timeIntervalSinceNow: 3600))
        
        datePicker.date = Date(timeIntervalSinceNow: 3600)
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkClipBoard), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }

    @objc func reminderPickerDateChanged(reminderPicker: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if datePicker.date < Date()
        {
            datePicker.date = Date(timeIntervalSinceNow: 120)
        }
        
        timeText.text = dateFormatter.string(from: datePicker.date)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc private func checkClipBoard() -> Void
    {
        if UIPasteboard.general.string != nil
        {
            var numberString = UIPasteboard.general.string
            
            numberString = numberString?.filter{ "+0123456789".contains($0)}
            
            if (numberString?.count)! >= 9
            {
                phoneText.text = numberString
            }
        }
        
        nameText.text = ""
    }
        
    @objc func DismissKeyboard(){
        //Causes the view to resign from the status of first responder.
        view.endEditing(true)
    }
    
}

