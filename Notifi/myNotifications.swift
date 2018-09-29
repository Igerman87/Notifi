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

class myNotifications: UIAlertController
{
    func initMyNotifications()
    {
        let callAction = UNNotificationAction(identifier: "CALL_ACTION", title: "Call now", options: UNNotificationActionOptions(rawValue: 0))
        
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: UNNotificationActionOptions(rawValue: 0))
        
        let snooze = UNNotificationAction(identifier: "SNOOZE", title: "Snooze", options: UNNotificationActionOptions(rawValue: 0))
        
        let notifiReminderCategory = UNNotificationCategory(identifier: "NOTIFI", actions: [callAction, dismissAction, snooze], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([notifiReminderCategory])
    }
    
    func createNotification(contact: NotifiContact, time: Date) -> Void
    {
        let notification = UNMutableNotificationContent()
        
        notification.title = "Its time to call: " + contact.FullName
        //notification.subtitle =
        notification.body = contact.ReminderPhoneNumber
        //notification.userInfo = ["NOTIFI_ID": notifiID, "USER_ID": ruserok]
        notification.categoryIdentifier = "NOTIFI"
        notification.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time.timeIntervalSinceNow > 60 ? time.timeIntervalSinceNow: 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Notifi", content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
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
