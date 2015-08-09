//
//  MJChannelViewController.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/9.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation
import MBProgressHUD
import Refresher

class MJChannelViewController : UITableViewController
{
    var channels : [Array<MJChannel>]!
        {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        // 设置 MJChannelViewController 为 MJChannelManager 的 delegate，当 channel 发生改变时，tableView  reload
        MJChannelManager.sharedManager.delegate = self
        channels = MJChannelManager.sharedManager.channels
        
        //TODO: 上拉刷新
        let beatAnimator = BeatAnimator(frame: CGRectMake(0, 0, 320, 80))
        tableView.addPullToRefreshWithAction({
            NSOperationQueue().addOperationWithBlock {
                MJChannelManager.sharedManager.updateChannels()
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.tableView.stopPullToRefresh()
                }
            }
            }, withAnimator: beatAnimator)
    }
    
    // MARK: Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return channels.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("channelCell") as! UITableViewCell
        cell.textLabel?.text = channels[indexPath.section][indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch(section)
        {
        case 0:
            title = "我的兆赫"
        case 1:
            title = "推荐兆赫"
        case 2:
            title = "上升最快兆赫"
        case 3:
            title = "热门兆赫"
        default:
            break
        }
        return title
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section==0 && indexPath.row==1 && MJUserInfoManager.sharedManager.userInfo.cookies=="")
        {
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = "还没有登录，赶紧登录哦！"
            hud.margin = 10
            hud.removeFromSuperViewOnHide = true
            hud.hide(true, afterDelay: 2.5)
            return;
        }
        
        let channel = channels[indexPath.section][indexPath.row]
        let dict = ["channel" : channel]
        NSNotificationCenter.defaultCenter().postNotificationName(MJChannelManager.Constants.MJChannelViewControllerDidSelectChannelNotification, object: nil, userInfo: dict)
    }
}

extension MJChannelViewController : MJChannelManagerDelegate
{
    func channelManagerdidUpdateChannel(manager: MJChannelManager) {
        channels = manager.channels
    }
}