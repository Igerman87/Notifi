//
//  pickerTableViewCell.swift
//  Notifi
//
//  Created by ilya_admin on 13/09/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class pickerTableViewCell: UITableViewCell
{
    var phoneContact: String = ""
    
    var isObserving = false
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var phoneButtonOutlet: UIButton!
    @IBOutlet weak var reminderTimeSelect: UILabel!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    
    @IBOutlet weak var reminderPicker: UIDatePicker!
    
    @IBAction func phoneButton(_ sender: Any)
    {
        
    }
    
    
    class var expendedHeight: CGFloat{get {return 330}}
    class var defaultHeight: CGFloat{get {return 44}}
    
    func checkHeight()
    {
        if (frame.size.height < pickerTableViewCell.expendedHeight)
        {
            titlelabel.font = UIFont.systemFont(ofSize: 17.0)
        }
        else
        {
            titlelabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        }
    }
    
    func watchFrameChages()
    {
        if !isObserving
        {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: nil)
            checkHeight()
            
            isObserving = true
        }
    }
    
    func ignoreFrameChanges()
    {
        if isObserving
        {
            removeObserver(self, forKeyPath:"frame")
            isObserving = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "frame"
        {
            checkHeight()  
        }
    }
    
    func Update(CellContact: inout NotifiContact )
    {
        
       // contact = CellContact // this should save the requested phone number
       
        titlelabel.text = CellContact.FullName
        reminderPicker.datePickerMode = UIDatePickerMode.dateAndTime

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        reminderTimeLabel.text = dateFormatter.string(from: reminderPicker.date)
        
        self.reminderPicker.addTarget(self, action: #selector(reminderPickerDateChanged), for: .valueChanged)

        PhoneNumberLabel.text = "Number: " + ((CellContact.PhoneNumbers[0].value).value(forKey: "digits") as! String)
        if CellContact.PhoneNumbers.count == 1
        {
            phoneButtonOutlet.isEnabled = false
        }
        else
        {
            phoneButtonOutlet.isEnabled = true
        }
    
    }
    
    @objc func reminderPickerDateChanged(reminderPicker: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        reminderTimeLabel.text = dateFormatter.string(from: reminderPicker.date)
    }
        


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
