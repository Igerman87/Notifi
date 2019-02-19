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
    
    override func viewDidLoad() {
        // empty
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
}
