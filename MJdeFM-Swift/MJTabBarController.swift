//
//  ViewController.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/6.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import UIKit
import SnapKit

class MJTabBarController: UITabBarController, UITableViewDelegate, UITableViewDataSource,
YALContextMenuTableViewDelegate{

    private var contextMenuTableView : YALContextMenuTableView!
    
    private var menuTitles :[String]!
    private var menuIcons :[UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initiateMenuOptions()
        self.initButton()
        
        let playerVC: AnyObject! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MJPlayerViewController")
        let channelsVC: AnyObject! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MJChannelViewController")
        let userInfoVC: AnyObject! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MJUserInfoViewController")
        
        self.viewControllers = [playerVC,channelsVC,userInfoVC]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.hidden = true;
        
        //移除UITabBarButton
        for child in self.tabBar.subviews{
            if child.isKindOfClass(UIControl)
            {
                child.removeFromSuperview()
            }
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.contextMenuTableView.reloadData()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        self.contextMenuTableView.updateAlongsideRotation()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: { (context) -> Void in
            //should be called after rotation animation completed
            self.contextMenuTableView.reloadData()
        })
        self.contextMenuTableView.updateAlongsideRotation()
    }

    
    // MARK : local
    func initiateMenuOptions()
    {
        self.menuTitles = [String](count:4, repeatedValue:"")
        
        self.menuIcons = [ UIImage(named: "menuClose"),
            UIImage(named: "menuPlayer"),
            UIImage(named: "menuChannel"),
            UIImage(named: "menuLogin")
        ]
    }
    
    func initButton()
    {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "menuIcon"), forState: UIControlState.Normal)
        button.addTarget(self, action:"presentMenuButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.snp_top).offset(3)
            make.right.equalTo(self.view.snp_right).offset(0)
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
    }
    
    func presentMenuButtonTapped()
    {
        if self.contextMenuTableView == nil{
            self.contextMenuTableView = YALContextMenuTableView(tableViewDelegateDataSource: self)
            self.contextMenuTableView.animationDuration = 0.15
            self.contextMenuTableView.yalDelegate = self;
            let cellNib = UINib(nibName: "ContextMenuCell", bundle: nil)
            self.contextMenuTableView.registerNib(cellNib, forCellReuseIdentifier: "rotationCell")
        }
        self.contextMenuTableView.showInView(self.view, withEdgeInsets: UIEdgeInsetsZero, animated: true)
    }
    
    // MARK : YALContextMenuTableViewDelegate
    func contextMenuTableView(contextMenuTableView: YALContextMenuTableView!, didDismissWithIndexPath indexPath: NSIndexPath!) {
        println("Menu dismissed with indexpath = \(indexPath)")
    }
    
    // MARK : UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let yaltableView = tableView as! YALContextMenuTableView
        yaltableView.dismisWithIndexPath(indexPath)
        switch indexPath.row
        {
        case 1,2,3:
            self.selectedIndex = indexPath.row-1
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuIcons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rotationCell", forIndexPath: indexPath) as! ContextMenuCell
        cell.backgroundColor = UIColor.clearColor()
        cell.menuTitleLabel.text = self.menuTitles[indexPath.row]
        cell.menuImageView.image = self.menuIcons[indexPath.row]
        return cell
    }
}

