//
//  NofitiData.swift
//  Notifi
//
//  Created by ilya_admin on 14/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import ContactsUI

@objc class NotifiContact : NSObject {
    
    @objc var FullName: String = ""
    @objc var PhoneNumbers: [CNLabeledValue<CNPhoneNumber>] = []
    @objc var Emails: [CNLabeledValue<NSString>] = []
    
    @objc var ReminderPhoneNumber: String = ""
    
    init(fullName: String, phoneNumbers: [CNLabeledValue<CNPhoneNumber>], emails: [CNLabeledValue<NSString>], reminderPhone: String ) {
        self.FullName = fullName
        self.PhoneNumbers = phoneNumbers
        self.Emails = emails
        self.ReminderPhoneNumber = reminderPhone
    }
    
}
