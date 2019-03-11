//
//  emailAgent.swift
//  Notifi
//
//  Created by ilya_admin on 16/02/2019.
//  Copyright © 2019 ilya_admin. All rights reserved.
//
import Foundation
import MessageUI
import UIKit

class emailClass: UIViewController, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    func sendEmail(messageBody:String) {
        
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["Sway4labs@gmail.com","ilya.german@gmail.com"])
        composeVC.setSubject("App <TBD> review")
        composeVC.setMessageBody("messageBody", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    private func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
