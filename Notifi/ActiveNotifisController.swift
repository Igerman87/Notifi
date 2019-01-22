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

var activeNotifiStructure:[String:[ActiveNotifiData]] = [:]
var completedNitifi: [ActiveNotifiData] = []

struct sectionData {
    var section:String
    var numOfActiveNotifi:Int
    var sectionLocation:Int
}

class ActiveNotifisController:TableViewController{
    
    
    var indexTitles: [String] = []
    var mainTable:[String] = ["Today", "Tomorrow", "Forthcoming"]
    var phoneNumberForCall = [String:String]()
    var selectedIndexPath: IndexPath?
    var activeNotifiCounterForTable:Int = 0
    var keyName:String = ""
    var selectedRowDataAssist:[String:sectionData] = [:]
    var selectedSection:sectionData = sectionData(section: "", numOfActiveNotifi: 0, sectionLocation: 0)
    
    var isFirstRun: Bool = true
    
    override func viewDidLoad()
    {        
        tableView.dataSource = self
        tableView.delegate = self
        //self.tableView.estimatedRowHeight = 90
                
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
 //       print(activeNotifiStructure.count)

        return 1//activeNotifiStructure.count

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
//        print(Array(activeNotifiStructure)[section].key)

        return ""// Array(activeNotifiStructure)[section].key
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if selectedIndexPath != nil && selectedIndexPath?.section == section
        {
            return 3  + activeNotifiStructure[keyName]!.count
        }
        else
        {
            return 3
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if selectedIndexPath != nil && keyName != "" && indexPath.row >= ((selectedRowDataAssist[keyName]?.sectionLocation)!) && indexPath.row <= ((selectedRowDataAssist[keyName]?.numOfActiveNotifi)! + (((selectedRowDataAssist[keyName]?.sectionLocation)!) - 1))
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_active_notifis", for: indexPath) as! ActiveNotifiCell
            
            let array = activeNotifiStructure[keyName]
            
            if array?.isEmpty == true
            {
                return cell
            }
            
            cell.Update(activeNotifi: array![indexPath.row - (selectedIndexPath?.row)!])
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id_active_dates", for: indexPath) as! ActiveNotifiDataTableCell
            
            cell.backgroundColor = UIColor.lightGray// UIColor.init(red: 240/255.0, green: 240/255.0, blue: 25.0/255.0, alpha: 0)
            
            var adjustNum: Int = 0
            
            if activeNotifiStructure[keyName] != nil && indexPath.row > 2
            {
                 adjustNum = ((activeNotifiStructure[keyName]?.count)!)
            }
            
            let array = activeNotifiStructure[mainTable[indexPath.row - adjustNum]]!
            
            if  mainTable[indexPath.row - adjustNum] == "Today"
            {
                UIApplication.shared.applicationIconBadgeNumber = array.count
            }
            
            cell.Update(number: String(array.count), name: mainTable[indexPath.row - adjustNum])
            

            
            return cell
        }
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
        selectedIndexPath = nil
        keyName = ""
        activeNotifiCounterForTable = 0
        updateTable()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: false)
        
        tableView.beginUpdates()
        
        if selectedIndexPath != nil && (selectedIndexPath!.row - 1) == indexPath.row
        {
            let rowToDelete = getRowsForTable()

            tableView.deleteRows(at: rowToDelete, with: .fade)
            selectedIndexPath = nil

            keyName = ""
        }
       else
        {
            if selectedIndexPath != nil
            {
                let rowToDelete = getRowsForTable()
                
                tableView.deleteRows(at: rowToDelete, with: .fade)
                keyName = ""
            }
            
            var rowsToIsert:[IndexPath] = []
            
           rowsToIsert = calculateRowsToInsert(indexPath: indexPath)
        
            tableView.insertRows(at: rowsToIsert, with: .fade)
        }
        tableView.endUpdates()
        
        tableView.scrollToRow(at: selectedIndexPath == nil ? IndexPath(row: 0, section: 0): selectedIndexPath!, at: .top, animated: true)
    }
    
    
    func calculateRowsToInsert(indexPath:IndexPath) -> [IndexPath]
    {
        var rowsToIsert:[IndexPath] = []

        if indexPath.row == 0
        {
            keyName = "Today"
            selectedIndexPath = IndexPath(row: 1, section: indexPath.section)
        }
        else if (indexPath.row == (tableView.numberOfRows(inSection: indexPath.section ) - 1))
        {
            keyName = "Forthcoming"
            selectedIndexPath = IndexPath(row: 3, section: indexPath.section)
        }
        else
        {
            keyName = "Tomorrow"
            selectedIndexPath = IndexPath(row: 2, section: indexPath.section)
        }
        
        rowsToIsert = getRowsForTable()

        
        return (rowsToIsert)
    }
    
    func getRowsForTable() -> [IndexPath]
    {
        var deleteIndexes:[IndexPath] = []
        
        let selectedSection = selectedRowDataAssist[keyName]
            
        print(selectedSection!.sectionLocation)
        print(selectedSection!.sectionLocation + selectedSection!.numOfActiveNotifi)
        
        for number in selectedSection!.sectionLocation..<(selectedSection!.sectionLocation + selectedSection!.numOfActiveNotifi)
        {
            deleteIndexes.append(IndexPath(row: number, section: 0))
        }

        
        return deleteIndexes
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return 0
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return nil
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let notifiToDeleteName = self.activeNotifiSectionTitles[indexPath.section]
//        let notifiToDeleteTime = "TODO"
//
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (UITableViewRowAction, indexPath) in
//
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifiToDeleteTime + ":00" + notifiToDeleteName])
//
//            self.updateTable()
//
//        }
//
//        let call = UITableViewRowAction(style: .normal, title: "Call") { (UITableViewRowAction, indexPath) in
//
//            let cell =  tableView.cellForRow(at: indexPath) as! ActiveNotifiCell
//
//            let phone = (self.phoneNumberForCall[cell.ActiveNotifiLabel.text! + self.activeNotifiSectionTitles[indexPath.section]])?.filter{ "+0123456789".contains($0)}
//
//            let phoneUrl = "tel://" + phone!
//
//            let url = URL(string: phoneUrl)
//
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifiToDeleteTime + ":00" + notifiToDeleteName])
//
//            self.updateTable()
//        }
//
//        call.backgroundColor = UIColor.green
//
//        return [delete,call]
//    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
     
        
        if editingStyle == .delete
        {
 
        }
    }
    

}

extension ActiveNotifisController
{
    @objc func updateTable() -> Void
    {
        allNotifis.removeAll()
        
        indexTitles.removeAll()
        selectedRowDataAssist.removeAll()
        
        activeNotifiStructure["Today"] = []
        activeNotifiStructure["Tomorrow"] = []
        activeNotifiStructure["Forthcoming"] = []
        
        group.enter()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
            
            for req in requests
            {
                if (req.content.categoryIdentifier == "NOTIFI")
                {
                    let fullName = req.content.subtitle
                    let phoneNumber = req.content.body.filter{ "+0123456789".contains($0)}
                    let phoneType = req.content.body.prefix(while: {$0 != ":"})
                    let time = req.identifier.prefix(16)
                    let identifier = req.identifier
                    
                    let picture = (contactsOneDimantion.filter({$0.FullName == fullName}).first)?.Picture ?? UIImage(named: "icons8-decision-filled")!
                    
                    let newNofiti = ActiveNotifiData(fullnameIn: fullName, phoneNumberIn: phoneNumber, phoneTypeIn: String(phoneType), timeIn: String(time), pictureIn: picture, indetifierIn: identifier)

                    completedNitifi.append(newNofiti)
                    
                    self.prepareTable(newNotifi: newNofiti)
                }
            }
            
            group.leave()
            
        })
        
        group.wait()
        
        selectedRowDataAssist["Today"] = sectionData(section: "Today", numOfActiveNotifi: (activeNotifiStructure["Today"]?.count)!, sectionLocation: 1)
        selectedRowDataAssist["Tomorrow"] = sectionData(section: "Tomorrow", numOfActiveNotifi: (activeNotifiStructure["Tomorrow"]?.count)!, sectionLocation: 2)
        selectedRowDataAssist["Forthcoming"] = sectionData(section: "Forthcoming", numOfActiveNotifi: (activeNotifiStructure["Forthcoming"]?.count)!, sectionLocation: 3)
        
        //indexTitles.sort()
        
        print(activeNotifiStructure)
        
        tableView.reloadData()
    }
    
    func prepareTable(newNotifi: ActiveNotifiData) -> Void
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let calendar = Calendar.current

        if calendar.isDateInToday(dateFormatter.date(from: newNotifi.time)!)
        {
            var array: [ActiveNotifiData] = activeNotifiStructure["Today"]!
            
            array.append(newNotifi)
            
            activeNotifiStructure["Today"] = array
        }
        else if calendar.isDateInTomorrow(dateFormatter.date(from: newNotifi.time)!)
        {
            var array: [ActiveNotifiData] = activeNotifiStructure["Tomorrow"]!
        
            array.append(newNotifi)
            
            activeNotifiStructure["Tomorrow"] = array
        }
        else
        {
            var array: [ActiveNotifiData] = activeNotifiStructure["Forthcoming"]!
            
            array.append(newNotifi)
            
            activeNotifiStructure["Forthcoming"] = array
        }
    }
}
