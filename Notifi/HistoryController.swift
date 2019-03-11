//
//  HistoryController.swift
//  Notifi
//
//  Created by ilya_admin on 17/02/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//

import Foundation
import UIKit

class historyController: UITableViewController {
    
    @IBAction func deleteAll(_ sender: Any)
    {
        if completedNitifi.isEmpty == false
        {
            let dateAlert = UIAlertController(title: "Delete all completed notifies ?", message: nil, preferredStyle: .alert)
            
            dateAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ (action) -> Void in
                
                completedNitifi.removeAll()
                
                self.tableView.reloadData()
                
                self.navigationController?.popViewController(animated: true)
            }))
            
            dateAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler:{ (action) -> Void in }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(dateAlert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad()
    {
        //empty
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return completedNitifi.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_history", for: indexPath) as! historyCell
            
            cell.update(activeStruct: completedNitifi[indexPath.row])
        
            return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? historyCell
    
        cellContactDetails = NotifiContact(fullName: (cell?.cellFullInfo.fullName)!, phoneNumbers: [], emails: [], Picture: (cell?.cellFullInfo.picture)!, reminderPhone: (cell?.cellFullInfo.phoneNumber)!)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (UITableViewRowAction, indexPath) in
            
            completedNitifi.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
        
        return[delete]
    }
}
