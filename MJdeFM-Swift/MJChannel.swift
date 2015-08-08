//
//  MJChannel.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

class MJChannel : NSObject
{
    let ID : String
    let name : String
    
    init(ID : String, name : String)
    {
        self.ID = ID
        self.name = name
        super.init()
    }
    
    convenience init(dictionary : Dictionary<String,String>)
    {
        let ID = dictionary["id"]
        let name = dictionary["name"]
        self.init(ID : ID!, name : name!)
    }
}
