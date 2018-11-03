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

var isFirstRun: Bool = true

var totalUpdateTime: Double = 0

class TableViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, UNUserNotificationCenterDelegate
{
    
    @IBOutlet weak var addNotifiOutlet: UIBarButtonItem!
    @IBAction func addNotifi(_ sender: Any)
    {
    
    }

    var searchController = UISearchController(searchResultsController: nil)
    var selectedIndexPath :IndexPath?
    var searchContacts: [NotifiContact] = []

 
    var isSearching: Bool = false
    
    override func viewDidLoad()
    {
        let start = Date()
        
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

        navigationItem.title = "Contacts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchContacts = contactsOneDimantion
        
        DispatchQueue.main.async
        {

            let localNotification = myNotifications()
            
            localNotification.initMyNotifications()
        }
 
        totalUpdateTime += Date().timeIntervalSince(start)
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
             //   print(Contacts[indexPath.section][indexPath.row - 1].FullName)
                
               cellpicker.Update(CellContact: Contacts[indexPath.section][indexPath.row - 1])
            }
            
            return cellpicker
        }
        else if selectedIndexPath != nil && indexPath.row > selectedIndexPath!.row && indexPath.section == selectedIndexPath?.section
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_name", for: indexPath) as! NameCell
            if isSearching
            {
                cell.Update(fullName: searchContacts[indexPath.row - 1].FullName)
            }
            else
            {
                cell.Update(fullName: Contacts[indexPath.section][indexPath.row - 1].FullName)
            }
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_name", for: indexPath) as! NameCell
            if isSearching
            {
                cell.Update(fullName: searchContacts[indexPath.row].FullName)
            }
            else
            {
                cell.Update(fullName: Contacts[indexPath.section][indexPath.row].FullName)
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
            print("selected index path ",selectedIndexPath!)
            tableView.insertRows(at: [selectedIndexPath!], with: .fade)
        }
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true )
        
//        let previousIndexPath = selectedIndexPath
//        
//        if indexPath == selectedIndexPath
//        {
//            selectedIndexPath = nil
//        }
//        else
//        {
//            selectedIndexPath = indexPath
//        }
//        
//        var indexPaths : Array<IndexPath> = []
//        if let previous = previousIndexPath
//        {
//            indexPaths = [previous]
//            
//        }
//        
//        if let current = selectedIndexPath
//        {
//            indexPaths = [current]
//        }
//        
//        if indexPaths.count > 0
//        {
//            tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
//        }
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
//    {
//        (cell as! pickerTableViewCell).watchFrameChages()
//    }
//
//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
//    {
//        (cell as! pickerTableViewCell).ignoreFrameChanges()
//
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if selectedIndexPath != nil && selectedIndexPath!.row == indexPath.row && selectedIndexPath!.section == indexPath.section
        {
            return 350
        }
        
        return 44
    }
    
    func calculateDatePickerIndexPath(indexPathSelected:IndexPath) -> IndexPath {
        
        if selectedIndexPath != nil && selectedIndexPath!.row < indexPathSelected.row && selectedIndexPath!.section == indexPathSelected.section
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
        if searchText == ""
        {
            searchBar.resignFirstResponder()
            
            isSearching = false
        }
        else
        {
            isSearching = true

            searchContacts = contactsOneDimantion.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
        }

       tableView.reloadData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
//        var visible:Bool = false
//
//        if selectedIndexPath != nil
//        {
//            for index in (tableView?.indexPathsForVisibleRows)!
//            {
//                if index.section == selectedIndexPath?.section
//                {
//                    visible = true
//
//                    break
//                }
//            }
//
//            if !visible
//            {
//                tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
//                selectedIndexPath = nil
//            }
//        }
    }
    
}
    

		
