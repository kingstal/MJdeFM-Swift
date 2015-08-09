//
//  MJSong.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

class MJSong : NSObject
{
    let title : String
    let artist : String
    let picture : String
    let length : String
    var like : String
    let url : String
    let sid : String

    init(title : String,
        artist : String,
        picture : String,
        length : String,
        like : String,
        url : String,
        sid : String) {
            self.title = title
            self.artist = artist
            self.picture = picture
            self.length = length
            self.like = like
            self.url = url
            self.sid = sid
            super.init()
    }
    
    convenience init(dictionary:Dictionary<String,String>)
    {
        let  artist = dictionary["artist"]
        let  title = dictionary["title"]
        let  url = dictionary["url"]
        let  picture = dictionary["picture"]
        let  length = dictionary["length"]
        let  like = dictionary["like"]
        let  sid = dictionary["sid"]
        self.init(title : title!,
            artist : artist!,
            picture : picture!,
            length : length!,
            like : like!,
            url : url!,
            sid : sid!)
    }
}
