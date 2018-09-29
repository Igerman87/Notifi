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



class TableViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, UNUserNotificationCenterDelegate
{
    
    @IBOutlet weak var addNotifiOutlet: UIBarButtonItem!
    @IBAction func addNotifi(_ sender: Any)
    {
    
    }
    
    
    
    var searchController = UISearchController(searchResultsController: nil)
    var selectedIndexPath :IndexPath?
    var Contacts: [[NotifiContact]] = []
    var sectionTitles: [String] = []
    var searchContacts: [NotifiContact] = []
    var contactsOneDimantion: [NotifiContact] = []
    var isSearching: Bool = false
    
    override func viewDidLoad()
    {
        let getContact = ContactServiceSorted()
        let localNotification = myNotifications()
        
        localNotification.initMyNotifications()
        
        (Contacts, sectionTitles, contactsOneDimantion) = getContact.fetchContacts()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false


        navigationItem.title = "Contacts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchContacts = contactsOneDimantion
 
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! pickerTableViewCell
        
        if isSearching
        {
            cell.Update(CellContact: searchContacts[indexPath.row])
        }
        else
        {
            cell.Update(CellContact: (Contacts[indexPath.section][indexPath.item]))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        searchController.searchBar.resignFirstResponder()
        
        let previousIndexPath = selectedIndexPath
        
        if indexPath == selectedIndexPath
        {
            selectedIndexPath = nil
        }
        else
        {
            selectedIndexPath = indexPath
        }
        
        var indexPaths : Array<IndexPath> = []
        if let previous = previousIndexPath
        {
            indexPaths = [previous]
            
        }
        
        if let current = selectedIndexPath
        {
            indexPaths = [current]
        }
        
        if indexPaths.count > 0
        {
            tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        (cell as! pickerTableViewCell).watchFrameChages()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        (cell as! pickerTableViewCell).ignoreFrameChanges()

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {

        if indexPath == selectedIndexPath
        {
            
            return pickerTableViewCell.expendedHeight
        }
        else
        {
            
            return pickerTableViewCell.defaultHeight
        }
 
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        
        selectedIndexPath = nil
        
        isSearching = false
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if searchBar.text != ""
        {
            isSearching = true
            
            searchBar.resignFirstResponder()

            searchContacts = contactsOneDimantion.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
            
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            searchBar.resignFirstResponder()
            
            isSearching = false
        }
//        else
//        {
//            isSearching = true
//
//            searchContacts = contactsOneDimantion.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
//        }

       tableView.reloadData()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        var ident: [String] = []
        
        ident.append(response.notification.request.identifier)
        
        switch response.actionIdentifier {
        case "CALL_ACTION":
            
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            let phoneNumber = "tel://\(response.notification.request.content.body)"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        case "SNOOZE":
            
           UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            let trig = UNTimeIntervalNotificationTrigger(timeInterval: 300.0, repeats: false)
            
            let request = UNNotificationRequest(identifier: "Notifi", content: response.notification.request.content, trigger: trig)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            break
            
        case "DISMISS_ACTION":
            
           UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            break
            
        default:
            break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
        var ident: [String] = []
        
        ident.append(notification.request.identifier)
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let phoneNumber = "tel://\(notification.request.content.body)"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}
		
