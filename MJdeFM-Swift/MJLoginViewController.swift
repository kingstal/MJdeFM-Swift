//
//  MJLoginViewController.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/8.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation
import MBProgressHUD

protocol MJLoginViewControllerDelegate : class {
    func loginViewControllerDidLoginSuccess(controller : MJLoginViewController, userInfo : MJUserInfo)
}

class MJLoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var captcha: UITextField!
    @IBOutlet weak var captchaBtn: UIButton!
    
    var captchaID : String!
    weak var delegate: MJLoginViewControllerDelegate?
    
    @IBAction func submitBtnTapped() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let name = username.text
        let passwd = password.text
        let capt = captcha.text
        
        MJFetcher.sharedManager.loginWithName(name, password: passwd, captcha: capt, captchaID: captchaID, rememberOnorOff: "off", successCompletion: {
            (data) in
                let userInfo = data as! MJUserInfo
                if userInfo.login == "0"
                {
                    self.delegate?.loginViewControllerDidLoginSuccess(self, userInfo: userInfo)
                }
            dispatch_async(dispatch_get_main_queue(), {
                ()in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            })
            }, errorCompletion: {
            (error) in
                 println("\(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    ()in
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
            })
    }
    
    @IBAction func cancelBtnTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func captchaBtnTapped() {
        self.loadCaptcha()
    }
    
    @IBAction func backgroundTapped(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCaptcha()
    }
    
    func loadCaptcha()
    {
        MJFetcher.sharedManager.fetchCaptchaImageURL({
            ( data ) in
            let result = data as! [String]
            self.captchaID = result[0]
            self.captchaBtn.setBackgroundImage(UIImage.loadImageWithUrl(result[1]), forState: UIControlState.Normal)
            }, errorCompletion: {
                ( error ) in
                println("\(error)")
        })
    }
}