//
//  MJUserInfoViewController.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/8.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

class MJUserInfoViewController : UIViewController
{
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var playedLabel: UILabel!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var bannedLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBAction func loginBtnTapped() {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MJLoginViewController") as! MJLoginViewController
        loginVC.delegate = self
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutBtnTapped() {
        //TODO: MBProgressHUD
        MJFetcher.sharedManager.logoutUser(userInfo, successCompletion: {
            (data) in
                self.userInfo = MJUserInfo()
                MJUserInfoManager.sharedManager.userInfo = self.userInfo
            }, errorCompletion: {
            (error) in
                println("\(error)")
        })
    }
    
    var userInfo : MJUserInfo!
    {
        didSet{
            if userInfo.cookies == ""
            {
                loginBtn.setBackgroundImage(UIImage(named: "login"), forState: UIControlState.Normal)
                loginBtn.userInteractionEnabled = true
                usernameLabel.hidden = true
                playedLabel.text = "0"
                likedLabel.text = "0"
                bannedLabel.text = "0"
                logoutBtn.hidden = true
                return
            }
            loginBtn.setBackgroundImage(UIImage.loadImageWithUrl("http://img3.douban.com/icon/ul\(userInfo!.userID)-1.jpg"), forState: UIControlState.Normal)
            loginBtn.userInteractionEnabled = false
            usernameLabel.text = userInfo!.name
            playedLabel.text = userInfo!.played
            likedLabel.text = userInfo!.liked
            bannedLabel.text = userInfo!.banned
            logoutBtn.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        userInfo = MJUserInfoManager.sharedManager.userInfo
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        loginBtn.layer.cornerRadius = loginBtn.frame.size.width / 2.0
        loginBtn.layer.masksToBounds = true
    }
}

extension MJUserInfoViewController : MJLoginViewControllerDelegate
{
    func loginViewControllerDidLoginSuccess(controller: MJLoginViewController, userInfo: MJUserInfo) {
        self.userInfo = userInfo
        MJUserInfoManager.sharedManager.userInfo = userInfo
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
