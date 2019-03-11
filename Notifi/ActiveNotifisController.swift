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
import MessageUI

var activeNotifiStructure:[String:[ActiveNotifiData]] = [:]
var completedNitifi: [ActiveNotifiData] = []
var iMinSessions = 10
var iTryAgainSessions = 7

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
    @IBOutlet var footer:UIButton!
    
    var keyName:String = ""
    var selectedRowDataAssist:[String:sectionData] = [:]
    var selectedSection:sectionData = sectionData(section: "", numOfActiveNotifi: 0, sectionLocation: 0)
    
    var isReschedule: Bool = false
    
    override func viewDidLoad()
    {        
        tableView.dataSource = self
        tableView.delegate = self
        
        addCompletedButton()
        

                
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
        
        rateMe()
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1//activeNotifiStructure.count

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
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
            
            if ((activeNotifiStructure[keyName] != nil) && keyName != "Forthcoming")//(indexPath.row > ((activeNotifiStructure[keyName]?.count)!)))
            {
                 adjustNum = ((activeNotifiStructure[keyName]?.count)!)
            }
            
            let finalIndex = (indexPath.row - adjustNum) > 0 ? (indexPath.row - adjustNum):indexPath.row
            
            let array = activeNotifiStructure[mainTable[finalIndex]]!
            
            if  mainTable[finalIndex] == "Today"
            {
                UIApplication.shared.applicationIconBadgeNumber = array.count
            }
            
            cell.Update(number: String(array.count), name: mainTable[finalIndex])
            

            
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
    
    override func viewWillDisappear(_ animated: Bool)
    {
        footer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if (footer != nil)
        {
            footer.isHidden = false
        }
        if isReschedule == true
        {
            
            updateTable()
            self.tabBarController?.tabBar.isHidden = false
            isReschedule = false
        }
        else
        {
            selectedIndexPath = nil
            keyName = ""
            
            updateTable()
            self.tabBarController?.tabBar.isHidden = false
            
            var row = 0
            
            if activeNotifiStructure["Today"]?.isEmpty != true
            {
                row = 0
            }
            else if activeNotifiStructure["Tomorrow"]?.isEmpty != true
            {
                row = 1
            }
            else if activeNotifiStructure["Forthcoming"]?.isEmpty != true
            {
                row = 2
            }
            
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: false)
        
        tableView.beginUpdates()
        
        let cell = tableView.cellForRow(at: indexPath) as? ActiveNotifiCell
        
        if cell != nil
        {
            cellContactDetails = NotifiContact(fullName: (cell?.cellFullInfo.fullName)!, phoneNumbers: [], emails: [], Picture: (cell?.cellFullInfo.picture)!, reminderPhone: (cell?.cellFullInfo.phoneNumber)!)
            
            ideftifierForActive = (cell?.cellFullInfo.indetifier)!
            oldReminderTime = (cell?.cellFullInfo.time)!
            isReschedule = true
        }
        else if selectedIndexPath != nil && (selectedIndexPath!.row - 1) == indexPath.row
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
        
        //tableView.scrollToRow(at: selectedIndexPath == nil ? IndexPath(row: 0, section: 0): selectedIndexPath!, at: .top, animated: true)
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let cell = tableView.cellForRow(at: indexPath) as? ActiveNotifiCell
        
        if cell == nil
        {
            return []
        }

        let delete = UITableViewRowAction(style: .default, title: "Delete") { (UITableViewRowAction, indexPath) in

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(cell?.cellFullInfo.indetifier)!])

            //et tempIndexPath = self.selectedIndexPath
            //let tempKeyName = self.keyName

//            self.selectedIndexPath = nil
//            self.keyName = ""
            
            self.updateTable()
  
            
        }

        let call = UITableViewRowAction(style: .default, title: "Call") { (UITableViewRowAction, indexPath) in

            let cell =  tableView.cellForRow(at: indexPath) as! ActiveNotifiCell
            
            let phone = cell.cellFullInfo.phoneNumber
            
            completedNitifi.reverse()
            
            completedNitifi.append(ActiveNotifiData(fullnameIn: cell.cellFullInfo.fullName, phoneNumberIn: cell.cellFullInfo.phoneNumber,       phoneTypeIn: cell.cellFullInfo.phoneType, timeIn: cell.cellFullInfo.time, pictureIn: UIImage(named: "icons8-decision-filled")!, indetifierIn: ""))
            
            completedNitifi.reverse()
            


            let phoneUrl = "tel://" + phone!

            let url = URL(string: phoneUrl)

            UIApplication.shared.open(url!, options: [:], completionHandler: nil)

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [cell.cellFullInfo.indetifier!])
            
            self.updateTable()
        }

        call.backgroundColor = UIColor.green

        return [delete,call]
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
                    
                    self.prepareTable(newNotifi: newNofiti)
                }
            }
            
            group.leave()
            
        })
        
        group.wait()
        
        selectedRowDataAssist["Today"] = sectionData(section: "Today", numOfActiveNotifi: (activeNotifiStructure["Today"]?.count)!, sectionLocation: 1)
        selectedRowDataAssist["Tomorrow"] = sectionData(section: "Tomorrow", numOfActiveNotifi: (activeNotifiStructure["Tomorrow"]?.count)!, sectionLocation: 2)
        selectedRowDataAssist["Forthcoming"] = sectionData(section: "Forthcoming", numOfActiveNotifi: (activeNotifiStructure["Forthcoming"]?.count)!, sectionLocation: 3)
        
        sortByTime()
        
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
    
    func sortByTime() {
        
        for key in activeNotifiStructure.keys
        {
            activeNotifiStructure[key] = activeNotifiStructure[key]!.sorted(by: {$0.time < $1.time})
        }
    }
    
    func addCompletedButton()
    {
        if footer == nil
        {
            footer = UIButton(frame: CGRect(x: 0, y: self.view.bounds.height - ((self.tabBarController?.tabBar.frame.size.height)! + 50 ), width: self.view.bounds.width, height: 50))
            footer.backgroundColor = UIColor.white
//            footer.layer.cornerRadius = 25
//            footer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
          //  footer.layer.borderColor = UIColor.lightGray.cgColor
          //  footer.layer.borderWidth = 1
            footer.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
            
            let borderTop = CALayer()
            borderTop.backgroundColor = UIColor.gray.cgColor
            borderTop.frame = CGRect(x: 0, y: 0, width: footer.frame.size.width, height: 0.5)
            
            let borderButtom = CALayer()
            borderButtom.backgroundColor = UIColor.gray.cgColor
            borderButtom.frame = CGRect(x: 0, y: footer.frame.size.height - 0.5 , width: footer.frame.size.width, height: 0.5)
            
            footer.layer.addSublayer(borderTop)
            footer.layer.addSublayer(borderButtom)
            
            footer.setTitle("Completed", for: .normal)
            footer.setTitleColor(UIColor.lightGray, for: .normal)
            footer.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            
            self.tabBarController!.view.addSubview(footer)
        }
    }
    @objc func showHistory()
    {
        self.performSegue(withIdentifier:"History", sender: self)
    }
}

extension ActiveNotifisController
{
    func rateMe() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        var numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        
        if ( (!neverRate && numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1)))
        {
            loveMe()
            numLaunches = iMinSessions + 1
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate Us", message: "Thanks for using <TBD>", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Rate <TBD>", style: UIAlertAction.Style.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1441138351?action=write-review")
                else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertAction.Style.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertAction.Style.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func negativeRate()
    {
        let alert = UIAlertController(title: "Please tell us why", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            
            self.sendEmail(messageBody: textField.text!)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loveMe()
    {
        
        let alert = UIAlertController(title: "Do you like using <TBD> ?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { alertAction in
            
            self.showRateMe()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            self.negativeRate()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ActiveNotifisController:MFMailComposeViewControllerDelegate
{
    
    func sendEmail(messageBody:String) {
        
        if !MFMailComposeViewController.canSendMail() {

            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["Sway4labs@gmail.com","ilya.german@gmail.com"])
        composeVC.setSubject("App <TBD> review")
        composeVC.setMessageBody(messageBody, isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,didFinishWith result: MFMailComposeResult,error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
