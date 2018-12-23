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

var allNotifis = [String:[String]]()

class TableViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate
{
    
    @IBOutlet weak var addNotifiOutlet: UIBarButtonItem!

    var searchController = UISearchController(searchResultsController: nil)
    var selectedIndexPath :IndexPath?
    var searchContacts: [NotifiContact] = []
 
    var isSearching: Bool = false
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if selectedIndexPath != nil
        {
            tableView.beginUpdates()
            tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
            selectedIndexPath = nil
            tableView.endUpdates()
        }
        
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
            if selectedIndexPath != nil && selectedIndexPath?.section == section
            {
                return searchContacts.count + 1
            }
            else
            {
                return searchContacts.count
            }
        }
        else
        {
            if selectedIndexPath != nil && selectedIndexPath?.section == section
            {
                return Contacts[section].count + 1
            }
            else
            {
                return Contacts[section].count
            }
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
        
        if selectedIndexPath != nil && selectedIndexPath!.row == indexPath.row && selectedIndexPath!.section == indexPath.section
        {
            let cellpicker = tableView.dequeueReusableCell(withIdentifier: "cell_id") as! pickerTableViewCell
            if isSearching
            {
                cellpicker.Update(CellContact: searchContacts[indexPath.row - 1])                
            }
            else
            {
               cellpicker.Update(CellContact: Contacts[indexPath.section][indexPath.row - 1])
            }
            
            return cellpicker
        }
        else if selectedIndexPath != nil && indexPath.row > selectedIndexPath!.row && indexPath.section == selectedIndexPath?.section
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_name", for: indexPath) as! NameCell
            if isSearching
            {
                cell.Update(CellContact: searchContacts[indexPath.row - 1])
            }
            else
            {
                cell.Update(CellContact: Contacts[indexPath.section][indexPath.row - 1])
            }
            
            return cell
        }
        else
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        searchController.searchBar.resignFirstResponder()
        
        tableView.beginUpdates()
        
        if selectedIndexPath != nil && selectedIndexPath!.row - 1 == indexPath.row && selectedIndexPath!.section == indexPath.section
        {
            tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
            selectedIndexPath = nil
        }
        else
        {
            if selectedIndexPath != nil
            {
                tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
            }
            
            selectedIndexPath = calculateDatePickerIndexPath(indexPathSelected: indexPath)
            tableView.insertRows(at: [selectedIndexPath!], with: .fade)
        }
        tableView.endUpdates()
        var scrolIndex = indexPath
        scrolIndex.row = scrolIndex.row > 0 ? scrolIndex.row - 1 : 0
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.scrollToRow(at: scrolIndex, at: .top, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if selectedIndexPath != nil && selectedIndexPath!.row == indexPath.row && selectedIndexPath!.section == indexPath.section
        {
            return 277
        }
        
        return 60 // Height for nameCell
    }
    
    func calculateDatePickerIndexPath(indexPathSelected:IndexPath) -> IndexPath {
        
        if selectedIndexPath != nil && selectedIndexPath!.row <= indexPathSelected.row && selectedIndexPath!.section == indexPathSelected.section
        {
            return IndexPath(row: indexPathSelected.row, section: indexPathSelected.section)
        }
        else
        {
            return IndexPath(row: indexPathSelected.row + 1, section: indexPathSelected.section)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        selectedIndexPath = nil
        
        isSearching = false
        
        tableView.reloadData()
    }

    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
//    {
//        if searchBar.text != ""
//        {
//            isSearching = true
//
//            searchBar.resignFirstResponder()
//
//            searchContacts = contactsOneDimantion.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
//
//            tableView.reloadData()
//        }
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if selectedIndexPath != nil
        {
            tableView.beginUpdates()
            tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
            selectedIndexPath = nil
            tableView.endUpdates()
        }
        
        if searchText == ""
        {
            searchContacts.removeAll()
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
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        allNotifis[response.notification.request.content.subtitle] = allNotifis[response.notification.request.content.subtitle]?.filter{$0 != response.notification.request.identifier}
        
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
        allNotifis[notification.request.content.subtitle] =
            allNotifis[notification.request.content.subtitle]?.filter{$0 != notification.request.identifier}
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        
        let phoneNumber = "tel://\(notification.request.content.body.filter{ "+0123456789".contains($0)})"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}

    

		
