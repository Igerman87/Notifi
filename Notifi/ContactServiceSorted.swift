//
//  ContactServiceSorted.swift
//  Notifi
//
//  Created by ilya_admin on 19/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class ContactServiceSorted
{
    let store = CNContactStore()
    var NotifiContacts: [NotifiContact] = []
    var NotifiContactsWithSections = [[NotifiContact]]()
    let collation = UILocalizedIndexedCollation.current()
    var sectionTitles = [String]()
    
    func fetchContacts() -> ([[NotifiContact]], [String], [NotifiContact])
    {

        
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactImageDataKey]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, error) -> Void in
                guard (contact.phoneNumbers.first?.value.stringValue) != nil  else {return}
                
                var contactImgae: UIImage?
                
                if contact.imageData != nil
                {
                    contactImgae = UIImage(data: contact.imageData!)
                }
                else
                {
                    contactImgae = UIImage(named: "icons8-decision-filled")
                }
                
                self.NotifiContacts.append(NotifiContact(fullName: contact.givenName + " " + contact.familyName, phoneNumbers: contact.phoneNumbers, emails: contact.emailAddresses, Picture:contactImgae!, reminderPhone:""))
            })
            
            self.setUpCollation()
         
            // use this for faster reload !!!
            //DispatchQueue.main.async {
              //  self.tableView.reloadData()
            }
            
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        
        return (self.NotifiContactsWithSections, self.sectionTitles, self.NotifiContacts)
    }
    
    @objc func setUpCollation()
    {
        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.NotifiContacts, collationStringSelector: #selector(getter: NotifiContact.FullName))
        self.NotifiContactsWithSections = arrayContacts as![[NotifiContact]]
        self.sectionTitles = arrayTitles
    }
}

extension UILocalizedIndexedCollation {
    //func for partition array in sections
    func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> (([AnyObject], [String]))
    {
        var unsortedSections = [[AnyObject]]()
        
        //Create array to hold the daya for each section
        for _ in self.sectionTitles
        {
            unsortedSections.append([])
        }
        
        //Put each object into section
        for item in array
        {
            let index:Int = self.section(for: item, collationStringSelector: collationStringSelector)
            unsortedSections[index].append(item)
        }
        
        //Sort the array for each section
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        
        for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
            sectionTitles.append(self.sectionTitles[index])
            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }
        }
        
        return (sections, sectionTitles)
    }
}
