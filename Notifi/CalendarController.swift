//
//  CalendarController.swift
//  Notifi
//
//  Created by ilya_admin on 25/12/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar
import UserNotifications

var cellContactDetails: NotifiContact!
var ideftifierForActive:String!
var oldReminderTime:String!

class CalendarController:  UIViewController
{
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var Year: UILabel!
    @IBOutlet weak var Month: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var remindMeButton: UIButton!
    
    let formatter = DateFormatter()
    
    @IBAction func addNotifi(_ sender: UIButton)
    {
        let time = checkTimeValidity(calendarDate: calendarView.selectedDates[0] , pickerDate: datePicker.date)
        
        if time > Date()
        {
            if ideftifierForActive != nil
            {                
                 UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:[ideftifierForActive!])
            }
            
            let myNotifi = myNotifications()

            let phoneMenu = UIAlertController(title: nil, message: "Choose number", preferredStyle: .actionSheet)
            
            phoneMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                              handler: {(alert:UIAlertAction!) ->Void in
                                                
                                                cellContactDetails.ReminderPhoneNumber = ""
            }))
            
            if cellContactDetails.PhoneNumbers.count > 1
            {
                var PhoneLabelToPhone = [String:String]()
                
                for phoneNumber in cellContactDetails.PhoneNumbers
                {
                    var phoneType = phoneNumber.label!
                    
                    if(phoneType.isEmpty)
                    {
                        phoneType = "phone"
                    }
                    else
                    {
                        let tempType = String(phoneType.drop(while: {$0 != "<"}).dropFirst().prefix(while: { $0 != "!" } ).dropLast())
                        
                        phoneType = tempType == "" ? phoneType:tempType
                    }
                    
                    phoneType = phoneType.lowercased()
                    
                    PhoneLabelToPhone[phoneType] = ((phoneNumber.value).value(forKey: "digits") as! String)
                    
                    phoneMenu.addAction(UIAlertAction(title: phoneType, style: .default,
                      handler: {(alert:UIAlertAction!) ->Void in
                        
                        cellContactDetails.ReminderPhoneNumber = PhoneLabelToPhone[alert.title!]!
                        cellContactDetails.ReminderType = phoneType
                        
                        myNotifi.createNotification(contact: cellContactDetails, Type:cellContactDetails.ReminderType, Time: time)
                       
                        self.showSuccessAlert()
                    }))
                }
                UIApplication.shared.keyWindow?.rootViewController?.present(phoneMenu, animated: true, completion:nil)
                
            }
            else
            {
                var phoneType:String = ""
                var phoneNumber:String = ""
                
                if cellContactDetails.ReminderPhoneNumber != ""
                {
                    phoneNumber = cellContactDetails.ReminderPhoneNumber
                    phoneType = "phone"
                }
                else
                {
                    phoneType = cellContactDetails.PhoneNumbers[0].label!
                    
                    if(phoneType.isEmpty)
                    {
                        phoneType = "phone"
                    }
                    else
                    {
                        phoneType = String(phoneType.drop(while: {$0 != "<"}).dropFirst().prefix(while: { $0 != "!" } ).dropLast())
                    }
                    
                    phoneNumber = ((cellContactDetails.PhoneNumbers[0].value).value(forKey: "digits") as! String)
                }
                
                cellContactDetails.ReminderPhoneNumber = phoneNumber
                myNotifi.createNotification(contact: cellContactDetails, Type:phoneType , Time: time)
                
                showSuccessAlert()
            }

        }
        else
        {
            let dateAlert = UIAlertController(title: nil, message: "Only future dates are valid", preferredStyle: .alert)

            dateAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (action) -> Void in  }))

            UIApplication.shared.keyWindow?.rootViewController?.present(dateAlert, animated: true, completion: nil)
            
            datePicker.date = Date(timeIntervalSinceNow: 120)
            calendarView.selectDates([Date()])
        }
        

    }
    
    override func viewDidLoad()
    {
        self.tabBarController?.tabBar.isHidden = true
        

        
        setupHeader()
    
        setupCalnedarView()
        
        setupDatePicker()
        
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        cellContactDetails = nil
        ideftifierForActive = nil
        oldReminderTime = nil
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController)
    {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupHeader()
    {
        let logoContainer = UIView(frame: CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width, height: 30))
        
        let label = UILabel(frame: CGRect(x: 40, y: 5, width: 100, height: 30))
        
        if cellContactDetails.FullName.count > 25
        {
            cellContactDetails.FullName = String(cellContactDetails.FullName.dropLast(cellContactDetails.FullName.count - 25))
        
            cellContactDetails.FullName.append("...")
        }
        
        label.text = cellContactDetails.FullName
        label.sizeToFit()
        //label.center = logoContainer.center
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = cellContactDetails.Picture
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 18
        
        let imageAspect = imageView.image!.size.width/imageView.image!.size.height
        
       imageView.frame = CGRect(x: 0, y: label.frame.origin.y - 6, width: (label.frame.size.height * imageAspect * 1.7),    height: label.frame.size.height * 1.7 )
        
        imageView.contentMode = .scaleAspectFit
        
        logoContainer.addSubview(label)
        logoContainer.addSubview(imageView)
        
        navigationItem.titleView = logoContainer
        
        logoContainer.sizeToFit()
    }
    
    func setupCalnedarView() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        let now = Date()
        
        if oldReminderTime != nil
        {
            calendarView.selectDates([dateFormatter.date(from: oldReminderTime)!])
            calendarView.scrollToDate(dateFormatter.date(from: oldReminderTime)!)
        }
        else if Calendar.current.isDateInTomorrow(now.addingTimeInterval(60 * 60)) == true
        {
            
            calendarView.selectDates([now.addingTimeInterval(60 * 60)])
        }
        else
        {
            calendarView.selectDates([now])
        }
    }
    
    func setupDatePicker()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let borderTop = CALayer()
        borderTop.backgroundColor = UIColor.gray.cgColor
        borderTop.frame = CGRect(x: 0, y: 0, width: datePicker.frame.size.width, height: 0.5)
        
        let borderButtom = CALayer()
        borderButtom.backgroundColor = UIColor.gray.cgColor
        borderButtom.frame = CGRect(x: 0, y: datePicker.frame.size.height - 0.5 , width: datePicker.frame.size.width, height: 0.5)
        
        datePicker.layer.addSublayer(borderTop)
        datePicker.layer.addSublayer(borderButtom)
        
        datePicker.layer.addSublayer(borderTop)
        datePicker.layer.addSublayer(borderButtom)
        
        if oldReminderTime != nil
        {
            
            datePicker.date = dateFormatter.date(from: oldReminderTime)!
        }
        else
        {
            datePicker.date = Date(timeIntervalSinceNow: 60 * 60)
        }
            
        datePicker.addTarget(self, action: #selector(datePickerDateChanged), for: .valueChanged)
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else {return}
        
        if cellState.isSelected
        {
            validCell.selectedView.isHidden = false
        }
        else
        {
            validCell.selectedView.isHidden = true
        }
        
        
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState)
    {
        guard let validCell = view as? CalendarCell else {return}
    
        if cellState.isSelected == true
        {
            validCell.dateValue.textColor = UIColor.white
        }
        else
        {
            if cellState.dateBelongsTo == .thisMonth
            {
                validCell.dateValue.textColor = UIColor.black
            }
            else
            {
                validCell.dateValue.textColor = UIColor.gray
            }
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo)
    {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        Year.text = formatter.string(from: date)
        
        
        formatter.dateFormat = "MMMM"
        Month.text = formatter.string(from: date)
    }
    
    func checkTimeValidity(calendarDate: Date, pickerDate: Date) -> Date
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var timeString = dateFormatter.string(from: calendarDate)
        
        dateFormatter.dateFormat = "HH:mm:00"
        
        timeString = timeString + " " + dateFormatter.string(from: pickerDate)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        return dateFormatter.date(from: timeString)!
    }
    
    @objc func datePickerDateChanged(reminderPicker: UIDatePicker)
    {
//        let timeAndDate = checkTimeValidity(calendarDate: calendarView.selectedDates[0], pickerDate: reminderPicker.date)
//        
//        if timeAndDate < Date()
//        {
//            reminderPicker.date = Date(timeIntervalSinceNow: 120)
//        }
    }
    
    func showSuccessAlert(){
        
        let alert = UIAlertController(title: "Notifi set successfuly", message: "I won't allow you to forget", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) -> Void in
            
            //  self.presentingViewController?.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now())
            {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }))
        
        if let presentedVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        {
            presentedVC.present(alert, animated: true, completion: nil)
        }
        else
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension CalendarController: JTAppleCalendarViewDataSource
{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calCell", for: indexPath)  as! CalendarCell
        
        cell.dateValue.text = cellState.text
        
    }
    
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = Date(timeIntervalSinceNow: 31536000) //Year from today
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    
}

extension CalendarController:JTAppleCalendarViewDelegate
{
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "calCell", for: indexPath)  as! CalendarCell
        
        cell.dateValue.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState)
    {
        let time = checkTimeValidity(calendarDate: date, pickerDate: datePicker.date)
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
//        if time < Date()
//        {
//            usleep(1000)
//
//            datePicker.date = Date(timeIntervalSinceNow: 120)
//            calendarView.selectDates([Date()])
//        }
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState)
    {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}
