//
//  ViewController.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import UIKit
import ContactsUI
import UserNotifications
let cellID = "cell_id"

let group = DispatchGroup()
var sectionTitles: [String] = []
var Contacts: [[NotifiContact]] = []
var contactsOneDimantion: [NotifiContact] = []


var allNotifis = [String:NotifiContact]()

class TableViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate
{
    
    @IBOutlet weak var addNotifiOutlet: UIBarButtonItem!

    var searchController = UISearchController(searchResultsController: nil)
    var searchContacts: [NotifiContact] = []
 
    var isSearching: Bool = false
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
        if isSearching
        {
            isSearching = false
            searchController.isActive = false
            
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }

    }
    
    override func viewDidLoad()
    {
        
        group.wait()
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        navigationItem.title = "Contacts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.keyboardDismissMode = .onDrag

        searchContacts = contactsOneDimantion
        
        DispatchQueue.main.async
        {

            let localNotification = myNotifications()
            
            localNotification.initMyNotifications()
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if isSearching
        {
            return 1
        }
        else
        {
            return sectionTitles.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSearching
        {
            return searchContacts.count
        }
        else
        {
            return Contacts[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if isSearching
        {
            return "Search results:"
        }
        else
        {
            return sectionTitles[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerTitle = view as? UITableViewHeaderFooterView
        {
            headerTitle.textLabel?.textColor = UIColor.blue
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        if isSearching
        {
            return nil
        }
        else
        {
            return sectionTitles
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return index
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_name", for: indexPath) as! NameCell
        if isSearching
        {
            cell.Update(CellContact: searchContacts[indexPath.row])
        }
        else
        {
            cell.Update(CellContact: Contacts[indexPath.section][indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: false)

        if isSearching
        {
            cellContactDetails = searchContacts[indexPath.row]
        }
        else
        {
            cellContactDetails = Contacts[indexPath.section][indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60 // Height for nameCell
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        isSearching = false
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        if searchText == ""
        {
            searchContacts = contactsOneDimantion
        }
        else
        {
            isSearching = true

            searchContacts = contactsOneDimantion.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
        }

       tableView.reloadData()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
        
//        if completedNitifi.isEmpty == true
//        {
//            if let data = UserDefaults.standard.value(forKey: "Completed") as? Data {
//                completedNitifi = try! JSONDecoder().decode([ActiveNotifiData].self, from: data)
//            }
//        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        
        
        switch response.actionIdentifier {
        case "CALL_ACTION":
            
            completedNitifi.append(ActiveNotifiData(fullnameIn: response.notification.request.content.subtitle, phoneNumberIn: response.notification.request.content.body,          phoneTypeIn: String(response.notification.request.content.body.prefix(while: {$0 != ":"})), timeIn: "", pictureIn: UIImage(named: "icons8-decision-filled")!, indetifierIn: ""))
            
            let phoneNumber = "tel://\(response.notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        case "SNOOZE":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type: "",Time: Date(timeIntervalSinceNow: 300), Alert: false)
            
            
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
            
            completedNitifi.append(ActiveNotifiData(fullnameIn: response.notification.request.content.subtitle, phoneNumberIn: response.notification.request.content.body,       phoneTypeIn: String(response.notification.request.content.body.prefix(while: {$0 != ":"})), timeIn: "", pictureIn: UIImage(named: "icons8-decision-filled")!, indetifierIn: ""))
            
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
        
        let phoneNumber = "tel://\(notification.request.content.body.filter{ "+0123456789".contains($0)})"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    func updateCompletedTable(response: UNNotificationResponse)
    {
//        let fullName = req.content.subtitle
//        let phoneNumber = req.content.body.filter{ "+0123456789".contains($0)}
//        let phoneType = req.content.body.prefix(while: {$0 != ":"})
//        let time = req.identifier.prefix(16)
//        let identifier = req.identifier
//
//        completedNitifi.append(ActiveNotifiData(fullnameIn: fullName, phoneNumberIn: phoneNumber, phoneTypeIn: phoneType, timeIn: time, pictureIn: <#T##UIImage#>, indetifierIn: <#T##String#>))
    }
}

    

		
