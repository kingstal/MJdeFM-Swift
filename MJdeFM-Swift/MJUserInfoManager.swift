//
//  MJUserInfoManager.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

private let sharedInstance = MJUserInfoManager()

class MJUserInfoManager
{
    class var sharedManager : MJUserInfoManager {
        return sharedInstance
    }
    
    var userInfo : MJUserInfo?
    {
        didSet{
            self.archiverUserInfo()
        }
    }
    
    func archiverUserInfo()
    {
        let file = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.UserDirectory, NSSearchPathDomainMask.UserDomainMask, true).first?.stringByAppendingPathComponent("userInfo.data")
        NSKeyedArchiver.archiveRootObject(userInfo!, toFile: file!)
    }
    
    func unarchiverUserInfo() -> MJUserInfo
    {
        let file = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.UserDirectory, NSSearchPathDomainMask.UserDomainMask, true).first?.stringByAppendingPathComponent("userInfo.data")
        return NSKeyedUnarchiver.unarchiveObjectWithFile(file!) as! MJUserInfo
    }
}