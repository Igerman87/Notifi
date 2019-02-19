//
//  randomViewController.swift
//  Notifi
//
//  Created by ilya_admin on 23/10/2018.
//  Copyright © 2018 ilya_admin. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications // debug
import Contacts

var randomImage:UIImage?
var iMinSessions = 7
var iTryAgainSessions = 14

class randomViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate
{
    var tempStringHolder:String = ""
    var myNot = myNotifications()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewCollectoin: UICollectionView!
    
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var newNameText: UITextField!
    @IBOutlet weak var fifteenButtonOutlet: UIButton!
    
    @IBAction func fifteenButton(_ sender: UIButton)
    {
        _ = setNotification(time: Date(timeIntervalSinceNow: 900))
    }
    @IBAction func oneHourButton(_ sender: Any)
    {
        _ = setNotification(time: Date(timeIntervalSinceNow: (60 *  60)))
    }

    @IBAction func fourHrButton(_ sender: Any)
    {
        _ = setNotification(time: Date(timeIntervalSinceNow: (60 * 60 * 4)))
    }
    @IBAction func twelveHrButton(_ sender: UIButton)
    {
        _ = setNotification(time: Date(timeIntervalSinceNow: (60 * 60 * 12)))
    }
    @IBAction func twenyFourHrButton(_ sender: UIButton)
    {
        _ = setNotification(time: Date(timeIntervalSinceNow: (60 * 60 * 24)))
    }
    @IBAction func elseButton(_ sender: UIButton)
    {
        let name = newNameText.text == "Name" ? "John Doe": newNameText.text!
        let values = validateNotifiValues()
        if values == true
        {
            cellContactDetails = NotifiContact(fullName: name, phoneNumbers: [], emails: [], Picture: randomImage ?? UIImage(named: "icons8-decision-filled")!, reminderPhone: phoneText.text!)

        }
        
    }
    

    
    override func viewWillAppear(_ animated: Bool)
    {
        checkClipBoard()
        self.tabBarController?.tabBar.isHidden = false
        viewCollectoin.reloadData()
        
        newNameText.text = "Name"
        phoneText.text = "Phone"
        randomImage = nil
    }

    override func viewDidLoad()
    {
//UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //completedNitifi.removeAll()
        
        viewCollectoin.delegate = self
        
        phoneText.delegate = self
        newNameText.delegate = self
        phoneText.keyboardType = UIKeyboardType.phonePad
        
        phoneText.tag = 1
        newNameText.tag = 2
        setupRandomBorders()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkClipBoard), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
     
        rateMe()
    }

    @objc func reminderPickerDateChanged(reminderPicker: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if datePicker.date < Date()
        {
            datePicker.date = Date(timeIntervalSinceNow: 120)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        view.endEditing(true)
        if textField.text == ""
        {
            if  textField.tag == 1
            {
                textField.text = "Phone"
            }
            else if textField.tag == 2
            {
                textField.text = "Name"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc private func checkClipBoard() -> Void
    {
        if UIPasteboard.general.string != nil
        {
            var numberString = UIPasteboard.general.string
            
            numberString = numberString?.filter{ "+0123456789".contains($0)}
            
            if (numberString?.count)! >= 9
            {
                phoneText.text = numberString
            }
        }
        
        newNameText.text = "Name"
    }
        
    @objc func DismissKeyboard(){
        //Causes the view to resign from the status of first responder.
        view.endEditing(true)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Random")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
        
        switch response.actionIdentifier {
        case "CALL_ACTION":
            
            let phoneNumber = "tel://\(response.notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        case "SNOOZE":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type:"",Time: Date(timeIntervalSinceNow: 300), Alert: false)
            
            
            break
            
        case "SNOOZE_HOUR":
            
            let snoozeNotifi = myNotifications()
            
            snoozeNotifi.createNotification(FullName: response.notification.request.content.subtitle,
                                            ReminderPhoneNumber: response.notification.request.content.body, Type: "", Time: Date(timeIntervalSinceNow: 3600), Alert: false)
            
            break
            
        case "DISMISS_ACTION":
            
            // nothing to do here
            break
            
        case "com.apple.UNNotificationDefaultActionIdentifier":
            
            let phoneNumber = "tel://\(response.notification.request.content.body.filter{ "+0123456789".contains($0)})"
            
            let url = URL(string: phoneNumber)
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
            break
            
        default:
            
            //nothing to do here
            
            break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        print("Random_will present")
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        
        let phoneNumber = "tel://\(notification.request.content.body.filter{ "+0123456789".contains($0)})"
        
        let url = URL(string: phoneNumber)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
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

extension randomViewController: UICollectionViewDelegate, UICollectionViewDataSource
{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return recentNotifi.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = viewCollectoin.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! randomCollectionCell

        if recentNotifi.count > indexPath.row
        {
            cell.update(data: recentNotifi[indexPath.row])
        }

        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        newNameText.text = recentNotifi[indexPath.row].fullName
        phoneText.text = recentNotifi[indexPath.row].phoneNumber
        randomImage = recentNotifi[indexPath.row].picture
    }

    func setupRandomBorders() {
        let borderTop = CALayer()
        borderTop.backgroundColor = UIColor.gray.cgColor
        borderTop.frame = CGRect(x: 0, y: 0, width: newNameText.frame.size.width, height: 0.5)
        
        let borderButtomName = CALayer()
        borderButtomName.backgroundColor = UIColor.gray.cgColor
        borderButtomName.frame = CGRect(x: 0, y: newNameText.frame.size.height - 0.5 , width: newNameText.frame.size.width, height: 0.5)

        let borderButtomPhone = CALayer()
        borderButtomPhone.backgroundColor = UIColor.gray.cgColor
        borderButtomPhone.frame = CGRect(x: 0, y: newNameText.frame.size.height - 0.5 , width: newNameText.frame.size.width, height: 0.5)
        
        newNameText.layer.addSublayer(borderButtomName)
        //newNameText.layer.addSublayer(borderTop)
        
        phoneText.layer.addSublayer(borderButtomPhone)
    }
    
    func validateNotifiValues() -> Bool
    {
        if phoneText.text == "Phone"
        {
            let alert = UIAlertController(title: "Notifi issue", message: "Phone number must be entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func setNotification(time:Date) -> Bool
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        
        view.endEditing(true)
        
        if phoneText.text == "Phone"
        {
            let alert = UIAlertController(title: "Notifi issue", message: "Phone number must be entered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
            return false
        }
        else
        {
            myNot.createNotification(FullName: newNameText.text == "Name" ? "John Doe": newNameText.text!,
                                     ReminderPhoneNumber: phoneText.text!, Type:"phone", Time:time, Alert: true)
            
            showSuccessAlert()
        }
        
        return true
    }
    
    func setupFonts(stringToChange: String) -> NSMutableAttributedString
    {
        let attributeString = NSMutableAttributedString(string: stringToChange)
        
        attributeString.addAttribute(.font, value: 21, range: NSRange(location: 0, length: 1))
        
        attributeString.addAttribute(.font, value: 15, range: NSRange(location: 1, length: stringToChange.count - 1))
        
        return attributeString
    }
}

extension randomViewController
{
    func rateMe() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        var numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        
        if (!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1)))
        {
            showRateMe()
            numLaunches = iMinSessions + 1
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: "Rate Us", message: "Thanks for using <TBD>", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Rate <TBD>", style: UIAlertAction.Style.default, handler: { alertAction in
            
         //  guard let writeReviewURL = URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=<1441138351>")
         //   else{fatalError("Expected valid URL")}
            guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1441138351?action=write-review")
                else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks", style: UIAlertAction.Style.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later", style: UIAlertAction.Style.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
//    func loveMe()
//    {
//        let alert = UIAlertController(title: "", message: "Do you like using <TBD> ?", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { alertAction in
//        
//            showRateMe()
//        }))
//            
//        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { alertAction in
//                
//                showRateMe()
//        }))
//    }
}
