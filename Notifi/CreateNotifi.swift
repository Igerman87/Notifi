//
//  CreateNotifi.swift
//  Notifi
//
//  Created by ilya_admin on 18/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import EventKit
import UserNotificationsUI

class CreateNotifi: UIAlertController
{
    var eventStore = EKEventStore()
    
    
    func setReminder(contact: NotifiContact, time: Date) -> Void {
        
        eventStore.requestAccess(to: .reminder, completion: {(granted, error) in
            
            if !granted
            {
                let alert = UIAlertController(title: "No permission No Notifi", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OH NO !!!", style: .default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            else
            {
//                let phoneNumber = "TEL://" + ((contact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
//                let phoneUrl: NSURL = URL(string: phoneNumber)! as NSURL
                
                
                let reminder = EKReminder(eventStore: self.eventStore)
                
                reminder.title = "Call: " + contact.FullName //+ " " + ((contact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
                
                reminder.addAlarm(EKAlarm(absoluteDate: time))
                reminder.notes = ((contact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                do {
                    try self.eventStore.save(reminder, commit: true)
                } catch let error {
                    
                    let alert = UIAlertController(title: "Problem setting Notifi", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    return
                }
                
                let alert = UIAlertController(title: "Notifi set successfuly", message: "Don't forget to call !!!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Great", style: .default, handler: nil))
                
                if let presentedVC = self.presentedViewController
                {
                    presentedVC.present(alert, animated: true, completion: nil)
                }
                else
                {
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                

            }
        })
        
        
        
        
        return
    }
    
}
