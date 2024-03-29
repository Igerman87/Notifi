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
        
        let screenHight = UIScreen.main.bounds.size.height
        let screenWeidth = UIScreen.main.bounds.size.width
        
        print(screenHight)
        print(screenWeidth)
        
        if screenHight == 667
        {
            let storyboard = UIStoryboard(name: "smallStoryBoard", bundle: nil)
    
            self.window!.rootViewController = storyboard.instantiateInitialViewController()
            
            self.window?.makeKeyAndVisible()
        }
        else if screenHight == 736 || screenWeidth >= 414
        {
            let storyboard = UIStoryboard(name: "bigStoryBoard", bundle: nil)
            
            self.window!.rootViewController = storyboard.instantiateInitialViewController()
            
            self.window?.makeKeyAndVisible()
        }
        
        // weird after download the first call wont get threw, only need to work for the first time
        if UserDefaults.standard.bool(forKey: "firstRun") == false
        {
            let url = URL(string: "0")
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)

            UserDefaults.standard.set(true, forKey: "firstRun")
        }
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts, completionHandler: {granted, error in
            
            if (granted)
            {
                group.enter()
                
                DispatchQueue.main.async
                {
                    let getContact = ContactServiceSorted()
                    
                    (Contacts, sectionTitles, contactsOneDimantion) = getContact.fetchContacts()
                    
                    group.leave()
                }
            }
            else
            {
                let alert = UIAlertController(title: "Notifi issue", message: "This app won't work without permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                
            }
        })

        UNUserNotificationCenter.current().delegate = self
        
        if let data = UserDefaults.standard.value(forKey: "Recent") as? Data {
            recentNotifi = try! JSONDecoder().decode([ActiveNotifiData].self, from: data)
        }

        if let completedData = UserDefaults.standard.value(forKey: "Completed") as? Data {
            completedNitifi = try! JSONDecoder().decode([ActiveNotifiData].self, from: completedData)
            
            completedNitifi.reverse()
        }
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
        
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


        
        if let data = try? JSONEncoder().encode(recentNotifi)
        {
            UserDefaults.standard.set(data, forKey: "Recent")
        }
        
        completedNitifi.reverse()
        
        if let completedData = try? JSONEncoder().encode(completedNitifi)
        {
            UserDefaults.standard.set(completedData, forKey: "Completed")
        }

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {

        completionHandler()
        
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
                                            ReminderPhoneNumber: response.notification.request.content.body, Type: String(response.notification.request.content.body.prefix(while: {$0 != ":"})),Time: Date(timeIntervalSinceNow: 300), Alert: false)
            
            
            break
            
        case "SNOOZE_HOUR":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type: String(response.notification.request.content.body.prefix(while: {$0 != ":"})), Time: Date(timeIntervalSinceNow: 3600), Alert: false)
            
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
        
        if let data = try? JSONEncoder().encode(completedNitifi)
        {
            UserDefaults.standard.set(data, forKey: "Completed")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        
        let alert = UIAlertController(title: "Call " + notification.request.content.subtitle + " ? ", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(UIAlertAction) -> Void in
            
            let phoneNumber = "tel://\(notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(UIAlertAction) -> Void in }))
            
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}

