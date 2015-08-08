//
//  MJFetcher.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/8.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let sharedInstance = MJFetcher()

class MJFetcher
{
    class var sharedManager : MJFetcher {
        return sharedInstance
    }
    
    typealias MJFetcherErrorBlock = (error : NSError) -> ()
    typealias MJFetcherSuccessBlock = (data : AnyObject) -> ()
    
    struct Constants {
        static let PLAYLISTURLFORMATSTRING = "http://douban.fm/j/mine/playlist?type=%@&sid=%@&pt=%f&channel=%@&from=mainsite"
        static let CAPTCHAIDURLSTRING = "http://douban.fm/j/new_captcha"
        static let CAPTCHAIMGURLFORMATSTRING = "http://douban.fm/misc/captcha?size=l&id=%@"
        static let LOGINURLSTRING = "http://douban.fm/j/login"
        static let LOGOUTURLSTRING = "http://douban.fm/partner/logout"
        static let ADDHEARTSONGURL = "http://douban.fm/j/song/%@/interest"
    }
    
    
    func fetchPlaylistwithType(type : String, song : MJSong?, passedTime : NSTimeInterval, channel : MJChannel, successCompletion: MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        let sid = (song == nil) ? "(null)" : song!.sid
        
        let playlistURLString = NSString(format: MJFetcher.Constants.PLAYLISTURLFORMATSTRING, type, sid, passedTime, channel.ID) as String
        
        Alamofire.request(.GET, playlistURLString)
            .responseJSON { _, _, json, error in
                if json != nil
                {
                    var songs = [MJSong]()
                    for songDict in JSON(json!)["song"]{
                        let songDict = songDict.1
                        if songDict["subtype"] == "T"
                        {
                            continue // subtype=T为广告标识位
                        }
                        let title = songDict["title"].stringValue
                        let artist = songDict["artist"].stringValue
                        let picture = songDict["picture"].stringValue
                        let length = songDict["length"].stringValue
                        let like = songDict["like"].stringValue
                        let url = songDict["url"].stringValue
                        let sid = songDict["sid"].stringValue
                        var song = MJSong(title: title, artist: artist, picture: picture, length: length, like: like, url: url, sid: sid)
                        songs.append(song)
                    }
                    successCompletion(data: songs)
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }
}