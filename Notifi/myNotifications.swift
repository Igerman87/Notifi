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
            
            let snooze = UNNotificationAction(identifier: "SNOOZE", title: "Remind me in 5 minutes", options: UNNotificationActionOptions(rawValue: 0))
            
            let snoozeHour = UNNotificationAction(identifier: "SNOOZE_HOUR", title: "Remind me in 1 hour", options: UNNotificationActionOptions(rawValue: 0))
            
            let notifiReminderCategory = UNNotificationCategory(identifier: "NOTIFI", actions: [callAction, dismissAction, snooze, snoozeHour], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
            
            UNUserNotificationCenter.current().setNotificationCategories([notifiReminderCategory])
            
            myNotifications.isFirstClassCreate = false
        }
    }
    
    func createNotification(contact: NotifiContact, Type:String, Time: Date) -> Void
    {
        randomImage = contact.Picture
        
        genericNotificationCreator(FullName: contact.FullName, ReminderPhoneNumber: contact.ReminderPhoneNumber,Type: Type, Time: Time, Alert: false)
    

    }
    
    func createNotification(FullName: String,ReminderPhoneNumber: String, Type:String, Time:Date, Alert:Bool) -> Void
    {
        genericNotificationCreator(FullName: FullName, ReminderPhoneNumber: ReminderPhoneNumber,Type: Type, Time: Time, Alert: Alert)
        
       // randomImage = contact.Picture
    }
    
    private func genericNotificationCreator (FullName: String,ReminderPhoneNumber: String,Type:String, Time:Date, Alert:Bool) -> Void
    {
        if randomImage != nil
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
            self.updateRecentNotifi(fullName: FullName, reminderPhoneNumber: ReminderPhoneNumber, picture: randomImage ?? UIImage(named: "icons8-decision-filled")!, type: Type)
 
  
            
            let stringTime = dateFormatter.string(from: Date())
            
            completedNitifi.reverse()
            
            completedNitifi.append(ActiveNotifiData(fullnameIn: FullName, phoneNumberIn: ReminderPhoneNumber, phoneTypeIn: Type, timeIn: stringTime, pictureIn: randomImage!, indetifierIn: ""))
            
            completedNitifi.reverse()
            
            randomImage = nil
        }
        
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
        
        let lowerType = Type.lowercased()
        
        if lowerType != ""
        {
            notification.body = lowerType + ": " + ReminderPhoneNumber
        }
        else
        {
            notification.body = ReminderPhoneNumber
        }

        notification.categoryIdentifier = "NOTIFI"
        notification.sound = UNNotificationSound.default
        
        notification.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Time.timeIntervalSinceNow > 60 ? Time.timeIntervalSinceNow: 60, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: dateFormatter.string(from: Time) + notification.body, content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(Error) -> Void in
        
            if Error == nil
            {
 
            }
        })
 

    }
    
    func updateRecentNotifi(fullName: String, reminderPhoneNumber: String, picture:UIImage, type:String)
        {
        
        if fullName != "John Doe"
        {

            
            let duplicateIndex = recentNotifi.firstIndex(where: {$0.fullName == fullName})
        
            if (duplicateIndex != nil)
            {
                for index in stride(from: duplicateIndex!, to: 0, by: -1)
                {
                    if index == 0
                    {
                        break;
                    }
                    recentNotifi.swapAt(index, index - 1)
                }
            }
            else
            {
                if recentNotifi.isEmpty
                {
                    recentNotifi.append(ActiveNotifiData(fullnameIn: fullName, phoneNumberIn: reminderPhoneNumber, phoneTypeIn:type, timeIn: "Hui2", pictureIn: picture, indetifierIn: "Hui3"))
                }
                else if recentNotifi.count < 7
                {
                    recentNotifi.append(recentNotifi[recentNotifi.count - 1])
                }
                
                for index in stride(from: recentNotifi.count == 7 ? 6:(recentNotifi.count - 1), to: 0, by: -1)
                {
                    if index == 0
                    {
                        break;
                    }
                    recentNotifi.swapAt(index, index - 1)
                }
            }

            recentNotifi[0] = ActiveNotifiData(fullnameIn: fullName, phoneNumberIn: reminderPhoneNumber, phoneTypeIn:type, timeIn: "Hui2", pictureIn: picture, indetifierIn: "Hui3")
        }
    }
}
