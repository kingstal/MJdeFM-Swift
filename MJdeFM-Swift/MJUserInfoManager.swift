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
        var filePath = NSString.getDocumentPath()
        filePath = filePath.stringByAppendingPathComponent("userInfo.data")
        NSKeyedArchiver.archiveRootObject(userInfo!, toFile: filePath)
    }
    
    func unarchiverUserInfo() -> MJUserInfo
    {
        var filePath = NSString.getDocumentPath()
        filePath = filePath.stringByAppendingPathComponent("userInfo.data")
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? MJUserInfo
        if userInfo != nil
        {
            return userInfo!
        }else
        {
            return MJUserInfo()
        }
    }
}