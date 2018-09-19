//
//  ContactService.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import ContactsUI

class ContactService
{
    func GetContacts() -> [NotifiContact]
    {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do
        {
            allContainers = try contactStore.containers(matching: nil)
        }
        catch
        {
            //shity store
        }
        
        var results: [CNContact] = []
        
        for container in allContainers
        {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do
            {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            }
            catch
            {
                //shity contact
            }
        }
        
        var NotifiContacts: [NotifiContact] = []
        
        for singleContact in results
        {
            if singleContact.givenName != "" || singleContact.familyName != ""
            {
                let appendContact =  NotifiContact(FullName: singleContact.familyName + " " + singleContact.givenName, PhoneNumbers: singleContact.phoneNumbers, Emails: singleContact.emailAddresses, ReminderPhoneNumber:"")
                
                NotifiContacts.append(appendContact)
            }
        }
        
        return NotifiContacts
    }
}
