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

class randomViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate
{
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewCollectoin: UICollectionView!
    
    @IBOutlet weak var phoneText: UITextField!
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
                                         ReminderPhoneNumber: phoneText.text!, Type:"Phone", Time:datePicker.date, Alert: true)
                
                showSuccessAlert()
            }
            else
            {
                let dateFormatterWithoutSeconds = DateFormatter()
                dateFormatterWithoutSeconds.dateFormat = "yyyy-MM-dd HH:mm"
                
                datePicker.date = Date(timeIntervalSinceNow: 120)
                
                
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
//UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        datePicker.datePickerMode = .dateAndTime
        self.datePicker.addTarget(self, action: #selector(reminderPickerDateChanged), for: .valueChanged)
        
        phoneText.delegate = self
        phoneText.keyboardType = UIKeyboardType.phonePad
        nameText.delegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
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
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        datePicker.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        view.endEditing(true)
        datePicker.isHidden = false
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        
        switch response.actionIdentifier {
        case "CALL_ACTION":
            
            let phoneNumber = "tel://\(response.notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        case "SNOOZE":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type:"",Time: Date(timeIntervalSinceNow: 300), Alert: false)
            
            
            break
            
        case "SNOOZE_HOUR":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type: "", Time: Date(timeIntervalSinceNow: 3600), Alert: false)
            
            break
            
        case "DISMISS_ACTION":
            
            // nothing to do here
            break
            
        case "com.apple.UNNotificationDefaultActionIdentifier":
            
            let phoneNumber = "tel://\(response.notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        default:
            
            //nothing to do here
            
            break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
       
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        
        let phoneNumber = "tel://\(notification.request.content.body.filter{ "+0123456789".contains($0)})"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    func showSuccessAlert(){
        
        let alert = UIAlertController(title: "Notifi set successfuly", message: "I won't allow you to forget", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) -> Void in
            
            //  self.presentingViewController?.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now())
            {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }))
        
        if let presentedVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        {
            presentedVC.present(alert, animated: true, completion: nil)
        }
        else
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension randomViewController: UICollectionViewDelegate, UICollectionViewDataSource
{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = viewCollectoin.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! randomCollectionCell

        if contactsOneDimantion.isEmpty == true
        {
            cell.update(data : NotifiContact(fullName: "Ananas", phoneNumbers: [], emails: [], Picture: UIImage(named: "icons8-decision-filled")!, reminderPhone: "Hui"))
        }
        else
        {
            //cell.update(data : contactsOneDimantion[indexPath.row])
        }
        
        return cell
    }
}
