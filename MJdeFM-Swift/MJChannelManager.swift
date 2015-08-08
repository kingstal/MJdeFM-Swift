//
//  MJChannelManager.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

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
    

    init()
    {
        self.addMyChannel()
        currentChannel = channels[0][0]
    }
    
    func addMyChannel()
    {
        //我的兆赫
        let privateChannel = MJChannel(ID: "0", name: "♪我的私人♪")
        let redheartChannel = MJChannel(ID: "-3", name: "我的红心")
        
        var myChannels = [ privateChannel, redheartChannel ]
        channels.append(myChannels)
    }
}