//
//  AppDelegate.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import UIKit
import UserNotifications
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts, completionHandler: {granted, error in
            
            if (!granted)
            {
                let alert = UIAlertController(title: "Notifi issue", message: "This app won't work without permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                
            }
        })

        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        allNotifis[response.notification.request.content.subtitle] = allNotifis[response.notification.request.content.subtitle]?.filter{$0 != response.notification.request.identifier}
        
        print(response.actionIdentifier)
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        
        switch response.actionIdentifier {
        case "CALL_ACTION":
            
            let phoneNumber = "tel://\(response.notification.request.content.body)"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        case "SNOOZE":
            
            let trig = UNTimeIntervalNotificationTrigger(timeInterval: 300.0, repeats: false)
            
            let request = UNNotificationRequest(identifier: response.notification.request.identifier, content: response.notification.request.content, trigger: trig)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            break
            
        case "DISMISS_ACTION":
            
            // nothing to do here
            break
            
        case "com.apple.UNNotificationDefaultActionIdentifier":
            
            let phoneNumber = "tel://\(response.notification.request.content.body)"
            
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
        allNotifis[notification.request.content.subtitle] =
            allNotifis[notification.request.content.subtitle]?.filter{$0 != notification.request.identifier}
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        
        let phoneNumber = "tel://\(notification.request.content.body)"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}

