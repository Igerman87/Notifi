//
//  ViewController.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import UIKit
import ContactsUI
let cellID = "cell_id"



class TableViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate
{

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var addNotifiOutlet: UIBarButtonItem!
    @IBAction func addNotifi(_ sender: Any)
    {
    
    }
    
    var selectedIndexPath :IndexPath?
    var Contacts: [[NotifiContact]] = []
    var sectionTitles: [String] = []
    var searchContacts: [[NotifiContact]] = []
    
    override func viewDidLoad()
    {
        // Contact service
        //let getContact = ContactService()
        //Contacts = getContact.GetContacts()
        
        let getContact = ContactServiceSorted()
        
        (Contacts, sectionTitles) = getContact.fetchContacts()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchContacts = Contacts
        
        searchBar.returnKeyType = .search
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = " Search..."
        
        addNotifiOutlet.isEnabled = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContacts[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView
        {
            headerTitle.textLabel?.textColor = UIColor.blue
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return index
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! pickerTableViewCell
        
        cell.Update(CellContact: (searchContacts[indexPath.section][indexPath.item]))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        searchBar.resignFirstResponder()
        
        let previousIndexPath = selectedIndexPath
        
        if indexPath == selectedIndexPath
        {
            selectedIndexPath = nil
            addNotifiOutlet.isEnabled = false
        }
        else
        {
            selectedIndexPath = indexPath
             addNotifiOutlet.isEnabled = true
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath
        {

            return pickerTableViewCell.expendedHeight
        }
        else
        {
            
            return pickerTableViewCell.defaultHeight
        }
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
//    {
//        if searchBar.text != ""
//        {
//            searchBar.resignFirstResponder()
//
//
//           // searchContacts = Contacts.filter {$0.FullName.range(of: searchBar.text!, options:.caseInsensitive) != nil }
//
//
//            // = Contacts.filter {$0.FullName.lowercased() == search?.lowercased()//  .contains(searchswi)}
//
//            tableView.reloadData()
//        }
//
//    }
    
    func searchBar(_searchBar: UISearchBar, textDidChange searchText: String)
    {
//        guard !searchText.isEmpty else { searchContacts = Contacts; return}
//
////        searchContacts = Contacts.filter({ (contact) -> Bool in
////            //guard var text = textSearched else {return false}
////            return contact.FullName.contains(searchText)
//        })

        //searchContacts.append(contentsOf:  Contacts.filter {$0.FullName == textSearched} //  ({$0.FullName == t})//  (where: {$0.name == textSearched})

        tableView.reloadData()
    }
}

