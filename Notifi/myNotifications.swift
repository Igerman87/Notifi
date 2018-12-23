//
//  myNotifications.swift
//  Notifi
//
//  Created by ilya_admin on 24/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

let semaphore = DispatchSemaphore(value: 1)

var localBadgeNumber = 0

func incrementBadge() -> Int
{
    semaphore.wait()
    
    localBadgeNumber += 1

    semaphore.signal()
    
    return localBadgeNumber
}

func decrementBadge() -> Int
{
    if localBadgeNumber > 0
    {
        semaphore.wait()
    
        localBadgeNumber -= 1
    
        semaphore.signal()
    }
    
    return localBadgeNumber
}

class myNotifications: UIAlertController
{
    static var isFirstClassCreate = true

    
    func initMyNotifications()
    {
        if (myNotifications.isFirstClassCreate)
        {
            let callAction = UNNotificationAction(identifier: "CALL_ACTION", title: "Call now", options: UNNotificationActionOptions(rawValue: 0))
            
            let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: UNNotificationActionOptions(rawValue: 0))
            
            let snooze = UNNotificationAction(identifier: "SNOOZE", title: "Remind me In 5 minutes", options: UNNotificationActionOptions(rawValue: 0))
            
            let snoozeHour = UNNotificationAction(identifier: "SNOOZE_HOUR", title: "Remind me In one hour", options: UNNotificationActionOptions(rawValue: 0))
            
            let notifiReminderCategory = UNNotificationCategory(identifier: "NOTIFI", actions: [callAction, dismissAction, snooze, snoozeHour], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
            
            UNUserNotificationCenter.current().setNotificationCategories([notifiReminderCategory])
            
            myNotifications.isFirstClassCreate = false
        }
    }
    
    func createNotification(contact: NotifiContact, Type:String, Time: Date) -> Void
    {
        genericNotificationCreator(FullName: contact.FullName, ReminderPhoneNumber: contact.ReminderPhoneNumber,Type: Type, Time: Time, Alert: true)
    }
    
    func createNotification(FullName: String,ReminderPhoneNumber: String, Type:String, Time:Date, Alert:Bool) -> Void
    {
        genericNotificationCreator(FullName: FullName, ReminderPhoneNumber: ReminderPhoneNumber,Type: Type, Time: Time, Alert: Alert)
    }
    
    private func genericNotificationCreator (FullName: String,ReminderPhoneNumber: String,Type:String, Time:Date, Alert:Bool) -> Void
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {granted, error in
            
            if !granted
            {
                let alert = UIAlertController(title: "Notifi issue", message: "This app won't work without permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
        })
        

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        let notification = UNMutableNotificationContent()
        
        notification.title = "Its time to call: "
        notification.subtitle = FullName
        print(Type)
        
        if Type != ""
        {
            notification.body = Type + ": " + ReminderPhoneNumber
        }
        else
        {
            notification.body = ReminderPhoneNumber
        }
            //notification.userInfo = ["NOTIFI_ID": notifiID, "USER_ID": ruserok]
        notification.categoryIdentifier = "NOTIFI"
        notification.sound = UNNotificationSound.default
        
        notification.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Time.timeIntervalSinceNow > 60 ? Time.timeIntervalSinceNow: 60, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: dateFormatter.string(from: Time) + FullName, content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        if allNotifis[FullName] != nil
        {
            allNotifis[FullName]?.append(dateFormatter.string(from: Time))
        }
        else
        {
            allNotifis[FullName] = []
            
            allNotifis[FullName]?.append(dateFormatter.string(from: Time))
        }
        
        if Alert
        {
            let alert = UIAlertController(title: "Notifi set successfuly", message: "I won't allow you to forget", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
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
}
