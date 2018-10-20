//
//  ActiveNotifisController.swift
//  Notifi
//
//  Created by ilya_admin on 12/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class ActiveNotifisController:TableViewController{
    
    var activeNotifiSectionTitles: [String] = []
    var isFirstRun: Bool = true
    
    override func viewDidLoad()
    {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        

        navigationItem.title = "Active Notifis"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        updateTable()
        
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return activeNotifiSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return activeNotifiSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (allNotifis[activeNotifiSectionTitles[section]]?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_active_notifis", for: indexPath) as! ActiveNotifiCell
        
        cell.Update(time:(allNotifis[activeNotifiSectionTitles[indexPath.section]]?[indexPath.row])!)
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        // Empty
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        // Empty
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        updateTable()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        
        // Empty for now
    }
    
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
//    {
//        return index
//    }
//
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
//    {
//        return activeNotifiSectionTitles
//    }
    
    func updateTable() -> Void
    {
        allNotifis.removeAll()
        activeNotifiSectionTitles.removeAll()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
            
            for req in requests
            {
                
                if (req.content.categoryIdentifier == "NOTIFI")
                {
                    if allNotifis[req.content.subtitle] != nil
                    {
                        allNotifis[req.content.subtitle]?.append(req.identifier)
                    }
                    else
                    {
                        allNotifis[req.content.subtitle] = []
                        
                        allNotifis[req.content.subtitle]?.append(req.identifier)
                    }
                }
            }
            
            if allNotifis.isEmpty
            {
                allNotifis[""] = []
                
                allNotifis[""]?.append("No reminders")
            }
            
        })
        while allNotifis.isEmpty
        {
            usleep(100)
        }
        
        for activeNotifi in allNotifis
        {
            activeNotifiSectionTitles.append(activeNotifi.key)
        }
        
        tableView.reloadData()
    }
}