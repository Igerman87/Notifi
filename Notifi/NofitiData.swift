//
//  NofitiData.swift
//  Notifi
//
//  Created by ilya_admin on 14/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import ContactsUI

struct NotifiContact {
    
    var FullName: String
    var PhoneNumbers: [CNLabeledValue<CNPhoneNumber>] = []
    var Emails: [CNLabeledValue<NSString>] = []
    
    var ReminderPhoneNumber: String = ""
    
}
