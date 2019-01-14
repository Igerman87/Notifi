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

var cellContactDetails: NotifiContact!

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
                        phoneType = "Phone"
                    }
                    else
                    {
                        phoneType = String(phoneType.drop(while: {$0 != "<"}).dropFirst().prefix(while: { $0 != "!" } ).dropLast())
                    }
                    
                    PhoneLabelToPhone[phoneType] = ((phoneNumber.value).value(forKey: "digits") as! String)
                    
                    phoneMenu.addAction(UIAlertAction(title: phoneType, style: .default,
                      handler: {(alert:UIAlertAction!) ->Void in
                        
                        cellContactDetails.ReminderPhoneNumber = PhoneLabelToPhone[alert.title!]!
                        cellContactDetails.ReminderType = phoneType
                        
                        myNotifi.createNotification(contact: cellContactDetails, Type:cellContactDetails.ReminderType, Time: time)
                        
                        self.presentingViewController?.dismiss(animated: true, completion: nil )

                    }))
                }
                UIApplication.shared.keyWindow?.rootViewController?.present(phoneMenu, animated: true, completion: {
                    
                })
            }
            else
            {
                var phoneType = cellContactDetails.PhoneNumbers[0].label!
                
                if(phoneType.isEmpty)
                {
                    phoneType = "Phone"
                }
                else
                {
                    phoneType = String(phoneType.drop(while: {$0 != "<"}).dropFirst().prefix(while: { $0 != "!" } ).dropLast())
                }
                
                cellContactDetails.ReminderPhoneNumber = ((cellContactDetails.PhoneNumbers[0].value).value(forKey: "digits") as! String)
                myNotifi.createNotification(contact: cellContactDetails, Type:phoneType , Time: time)

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
        
//        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad()
    {
        self.tabBarController?.tabBar.isHidden = true   
        
        setupHeader()
    
        setupCalnedarView()
        
        setupDatePicker()
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController)
    {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupHeader()
    {
        let logoContainer = UIView(frame: CGRect(x: 30, y: 0, width: 270, height: 30))
        
        let label = UILabel()
        label.text = cellContactDetails.FullName
        label.sizeToFit()
        label.center = logoContainer.center
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = cellContactDetails.Picture
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 18
        
        let imageAspect = imageView.image!.size.width/imageView.image!.size.height
        
       imageView.frame = CGRect(x: label.frame.origin.x - label.frame.size.height * imageAspect - 30, y: label.frame.origin.y - 8, width: (label.frame.size.height * imageAspect * 1.7),    height: label.frame.size.height * 1.7 )
        
        imageView.contentMode = .scaleAspectFit
        
        logoContainer.addSubview(label)
        logoContainer.addSubview(imageView)
        
        navigationItem.titleView = logoContainer
        
        logoContainer.sizeToFit()
    }
    
    func setupCalnedarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        calendarView.selectDates([Date()])

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
        
        datePicker.date = Date(timeIntervalSinceNow: 60 * 60)
        
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
