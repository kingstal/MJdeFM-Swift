//
//  MJUserInfo.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

class MJUserInfo : NSObject, NSCoding{
    let login :String
    let cookies :String
    let userID :String
    let name :String
    let banned :String
    let liked :String
    let played :String
    
    init(login : String,
        cookies : String,
        userID : String,
        name : String,
        banned : String,
        liked : String,
        played : String)
    {
        self.login = login
        self.cookies = cookies
        self.userID = userID
        self.name = name
        self.banned = banned
        self.liked = liked
        self.played = played
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        login = aDecoder.decodeObjectForKey("login") as! String
        cookies = aDecoder.decodeObjectForKey("cookies") as! String
        userID = aDecoder.decodeObjectForKey("userID") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        banned = aDecoder.decodeObjectForKey("banned") as! String
        liked = aDecoder.decodeObjectForKey("liked") as! String
        played = aDecoder.decodeObjectForKey("played") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(login, forKey: "login")
        aCoder.encodeObject(cookies, forKey: "cookies")
        aCoder.encodeObject(userID, forKey: "userID")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(banned, forKey: "banned")
        aCoder.encodeObject(liked, forKey: "liked")
        aCoder.encodeObject(played, forKey: "played")
    }
}
