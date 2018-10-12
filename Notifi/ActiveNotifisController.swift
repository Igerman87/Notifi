//
//  ActiveNotifisController.swift
//  Notifi
//
//  Created by ilya_admin on 12/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class ActiveNotifisController:TableViewController  {
    
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
}
