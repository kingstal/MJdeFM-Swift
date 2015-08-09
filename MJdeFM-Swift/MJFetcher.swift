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

    func fetchCaptchaImageURL(successCompletion : MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        Alamofire.request(.GET, MJFetcher.Constants.CAPTCHAIDURLSTRING)
            .responseString { _, _, data, error in
                if data != nil
                {
                    var captchaID = data!
                    captchaID = captchaID.stringByReplacingOccurrencesOfString("\"", withString: "")
                    let captchaImageURL = NSString(format: MJFetcher.Constants.CAPTCHAIMGURLFORMATSTRING, captchaID)
                    successCompletion(data: [captchaID, captchaImageURL])
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }
    
    func loginWithName(name : String, password : String, captcha : String, captchaID : String, rememberOnorOff : String, successCompletion : MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        let loginParameters = [
            "source" : "radio",
            "alias" : name,
            "form_password" : password,
            "captcha_solution" : captcha,
            "captcha_id" : captchaID,
            "remember" : rememberOnorOff
        ]
        
        Alamofire.request(.POST, MJFetcher.Constants.LOGINURLSTRING, parameters: loginParameters)
            .responseJSON { _, _, json, error in
                if json != nil{
                    let userDict = JSON(json!)
                    let userInfoDict = userDict["user_info"]
                    let playRecordDict = userInfoDict["play_record"]
                    let login = userDict["r"].stringValue
                    let cookies = userInfoDict["ck"].stringValue
                    let userID = userInfoDict["uid"].stringValue
                    let name = userInfoDict["name"].stringValue
                    let banned = playRecordDict["banned"].stringValue
                    let liked = playRecordDict["liked"].stringValue
                    let played = playRecordDict["played"].stringValue
                    let userInfo = MJUserInfo(login: login, cookies: cookies, userID: userID, name: name, banned: banned, liked: liked, played: played)
                    successCompletion(data: userInfo)
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }

    func logoutUser(user : MJUserInfo, successCompletion : MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        let logoutParameters = [
            "source" : "radio",
            "ck" : user.cookies,
            "no_login" : "y"
        ]

        Alamofire.request(.GET, MJFetcher.Constants.LOGOUTURLSTRING, parameters : logoutParameters)
            .responseString { _, _, data, error in
                if data != nil
                {
                    successCompletion(data: data!)
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }
    
    func addHeartSongToUser(user : MJUserInfo, song : MJSong, action : String, successCompletion : MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        let parameters = [
            "ck" : user.cookies,
            "action" : action
        ]
        
        Alamofire.request(.POST, String(format: MJFetcher.Constants.ADDHEARTSONGURL, song.sid), parameters : parameters)
            .responseString { _, _, data, error in
                if data != nil
                {
                    successCompletion(data: data!)
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }
    
    func fetchChannelWithURL(url : String, successCompletion : MJFetcherSuccessBlock, errorCompletion : MJFetcherErrorBlock)
    {
        Alamofire.request(.GET, url)
            .responseJSON { _, _, data, error in
                if data != nil
                {
                    successCompletion(data: data!)
                }else if error != nil{
                    errorCompletion(error: error!)
                }
        }
    }
}