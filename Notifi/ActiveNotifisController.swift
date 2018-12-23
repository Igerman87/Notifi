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
    var indexTitles: [String] = []
    var phoneNumberForCall = [String:String]()
    
    var isFirstRun: Bool = true
    
    override func viewDidLoad()
    {        
        tableView.dataSource = self
        tableView.delegate = self
        //self.tableView.estimatedRowHeight = 90
        
        UNUserNotificationCenter.current().delegate = self
        
//        searchController.searchBar.sizeToFit()
//        searchController.searchBar.returnKeyType = .search
//        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
//        searchController.searchBar.placeholder = " Search..."
//        searchController.searchBar.delegate = self
//        searchController.dimsBackgroundDuringPresentation = false
        UNUserNotificationCenter.current().delegate = self

        navigationItem.title = "Active Reminders"
        navigationItem.searchController = nil
        navigationItem.hidesSearchBarWhenScrolling = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        
        let phoneNumber = phoneNumberForCall[((allNotifis[activeNotifiSectionTitles[indexPath.section]]?[indexPath.row])!) + activeNotifiSectionTitles[indexPath.section]]
        
        cell.Update(time:(allNotifis[activeNotifiSectionTitles[indexPath.section]]?[indexPath.row])!, phone: phoneNumber ?? "")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return index
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return indexTitles
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let notifiToDeleteName = self.activeNotifiSectionTitles[indexPath.section]
        let notifiToDeleteTime = allNotifis[notifiToDeleteName]![indexPath.row]
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (UITableViewRowAction, indexPath) in
        
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifiToDeleteTime + ":00" + notifiToDeleteName])
            
            self.updateTable()

        }
        
        let call = UITableViewRowAction(style: .normal, title: "Call") { (UITableViewRowAction, indexPath) in
            
            let cell =  tableView.cellForRow(at: indexPath) as! ActiveNotifiCell
            
            let phone = (self.phoneNumberForCall[cell.ActiveNotifiLabel.text! + self.activeNotifiSectionTitles[indexPath.section]])?.filter{ "+0123456789".contains($0)}

            let phoneUrl = "tel://" + phone!
            
            let url = URL(string: phoneUrl)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifiToDeleteTime + ":00" + notifiToDeleteName])
            
            self.updateTable()
        }
        
        call.backgroundColor = UIColor.green
        
        return [delete,call]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == .delete
        {
 
        }
    }
    
    @objc func updateTable() -> Void
    {
        allNotifis.removeAll()
        activeNotifiSectionTitles.removeAll()
        indexTitles.removeAll()
        
        group.enter()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
            
            for req in requests
            {
                
                if (req.content.categoryIdentifier == "NOTIFI")
                {
                    if allNotifis[req.content.subtitle] != nil
                    {
    
                        allNotifis[req.content.subtitle]?.append(String(req.identifier.prefix(16)))
                    }
                    else
                    {
                        allNotifis[req.content.subtitle] = []
                        
                        allNotifis[req.content.subtitle]?.append(String(req.identifier.prefix(16)))
                    }
                    
                    self.phoneNumberForCall[String(req.identifier.prefix(16)) + req.content.subtitle] = req.content.body
                    
                }
            }
            
            group.leave()
            
        })
        
        group.wait()

        if allNotifis.isEmpty
        {
            allNotifis[""] = []
            
            allNotifis[""]?.append("No reminders")
        }
        
        for activeNotifi in allNotifis
        {
            activeNotifiSectionTitles.append(activeNotifi.key)
        }
        
        for index in activeNotifiSectionTitles
        {
            if !(indexTitles.contains(String(index.prefix(1))))
            {
                indexTitles.append(String(index.prefix(1)))
            }
        }
        
        indexTitles.sort()

        
        
        tableView.reloadData()
    }
}
