//
//  CreateNotifi.swift
//  Notifi
//
//  Created by ilya_admin on 18/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import EventKit

class CreateNotifi
{
    var eventStore = EKEventStore()
    
    
    func setReminder(contact: NotifiContact) -> Bool {
        
        let reminder = EKReminder(eventStore: self.eventStore)
    
        reminder.title = "Call: " + contact.FullName + ((contact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch _ {
            return false
        }
        
        return true
    }
    
}
