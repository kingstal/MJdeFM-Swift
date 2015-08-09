//
//  MJChannelManager.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MJChannelManagerDelegate : class {
    func channelManagerdidUpdateChannel(manager : MJChannelManager)
}


private let sharedInstance = MJChannelManager()
class MJChannelManager {
    class var sharedManager : MJChannelManager {
        return sharedInstance
    }
    
    struct Constants {
        static let MJChannelViewControllerDidSelectChannelNotification = "MJChannelViewControllerDidSelectChannelNotification"
        static let LOGINCHANNEL  = "http://douban.fm/j/explore/get_login_chls?uk=%@"
        static let RECOMMENDCHANNEL = "http://douban.fm/j/explore/get_recommend_chl"
        static let TRENDINGCHANNEL = "http://douban.fm/j/explore/up_trending_channels"
        static let HOTCHANNEL = "http://douban.fm/j/explore/hot_channels"
    }
    
    var currentChannel : MJChannel?
    var channels = [Array<MJChannel>]()
    weak var delegate: MJChannelManagerDelegate?

    init()
    {
        self.addMyChannel()
        currentChannel = channels[0][0]
    }
    
    func updateChannels()
    {
        channels.removeAll(keepCapacity: false)
        self.addMyChannel()
        self.addRecommendChannel()
        self.addTrendingChannel()
        self.addHotChannel()
    }
    
    func addMyChannel()
    {
        //我的兆赫
        let privateChannel = MJChannel(ID: "0", name: "♪我的私人♪")
        let redheartChannel = MJChannel(ID: "-3", name: "我的红心")
        
        var myChannels = [ privateChannel, redheartChannel ]
        channels.append(myChannels)
    }
    
    func addRecommendChannel()
    {
        var recommendChannels = [MJChannel]()
        let cookies = MJUserInfoManager.sharedManager.userInfo.cookies
        if  cookies == ""
        {
            MJFetcher.sharedManager.fetchChannelWithURL(MJChannelManager.Constants.RECOMMENDCHANNEL, successCompletion: {
                (data) in
                let channelDict = JSON(data)["data"]["res"]
                let ID = channelDict["id"].stringValue
                let name = channelDict["name"].stringValue
                recommendChannels.append(MJChannel(ID: ID, name: name))
                self.channels.append(recommendChannels)
                self.delegate?.channelManagerdidUpdateChannel(self)
                }, errorCompletion: {
                    (error) in
                    println("\(error)")
            })
        }else
        {
            MJFetcher.sharedManager.fetchChannelWithURL(String(format: MJChannelManager.Constants.LOGINCHANNEL, cookies), successCompletion: {
                (data) in
                let channelDicts = JSON(data)["data"]["res"]["rec_chls"]
                for (index: String, subJson: JSON) in channelDicts {
                    let ID = subJson["id"].stringValue
                    let name = subJson["name"].stringValue
                    recommendChannels.append(MJChannel(ID: ID, name: name))
                }
                self.channels.append(recommendChannels)
                self.delegate?.channelManagerdidUpdateChannel(self)
                }, errorCompletion: {
                    (error) in
                    println("\(error)")
            })
        }
    }
    
    func addTrendingChannel()
    {
        var trendingChannels = [MJChannel]()
        MJFetcher.sharedManager.fetchChannelWithURL(MJChannelManager.Constants.TRENDINGCHANNEL, successCompletion: {
            (data) in
            let channelDicts = JSON(data)["data"]["channels"]
            for (index: String, subJson: JSON) in channelDicts {
                let ID = subJson["id"].stringValue
                let name = subJson["name"].stringValue
                trendingChannels.append(MJChannel(ID: ID, name: name))
            }
            self.channels.append(trendingChannels)
            self.delegate?.channelManagerdidUpdateChannel(self)
            }, errorCompletion: {
                (error) in
                println("\(error)")
        })
    }
    
    func addHotChannel()
    {
        var hotChannels = [MJChannel]()
        
        MJFetcher.sharedManager.fetchChannelWithURL(MJChannelManager.Constants.HOTCHANNEL, successCompletion: {
            (data) in
            let channelDicts = JSON(data)["data"]["channels"]
            for (index: String, subJson: JSON) in channelDicts {
                let ID = subJson["id"].stringValue
                let name = subJson["name"].stringValue
                hotChannels.append(MJChannel(ID: ID, name: name))
            }
            self.channels.append(hotChannels)
            self.delegate?.channelManagerdidUpdateChannel(self)
            }, errorCompletion: {
                (error) in
                println("\(error)")
        })
    }
}