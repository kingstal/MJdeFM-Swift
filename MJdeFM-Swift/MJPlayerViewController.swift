//
//  MJPlayerViewController.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/7.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import MBProgressHUD


class MJPlayerViewController : UIViewController
{
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var pictureBlock: UIButton!
    @IBOutlet weak var timerProgressBar: UIProgressView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    let player = MPMoviePlayerController()
    var playList  = [MJSong]()
    var playingSong : MJSong?
    {
        didSet{
            player.contentURL = NSURL(string: playingSong!.url)
            player.play()
            currentSongIndex++;
            
            songTitle.text = playingSong!.title;
            songArtist.text = playingSong!.artist;
            channelTitle.text = MJChannelManager.sharedManager.currentChannel?.name
            picture.image = UIImage.loadImageWithUrl(playingSong!.picture)
            if (playingSong!.like == "0") {
                likeBtn.setBackgroundImage(UIImage(named: "heart1"), forState: UIControlState.Normal)
            } else {
                likeBtn.setBackgroundImage(UIImage(named: "heart2"), forState: UIControlState.Normal)
            }
            
            //初始化timeLabel的总时间
            let totalTimeSeconds = playingSong!.length.toInt()! % 60
            let totalTimeMinutes = playingSong!.length.toInt()! / 60
            if (totalTimeSeconds < 10) {
                totalTimeString = "\(totalTimeMinutes):0\(totalTimeSeconds)"
            } else {
                totalTimeString = "\(totalTimeMinutes):\(totalTimeSeconds)"
            }
            timer.fireDate = NSDate()
            
            // 设置锁屏界面的播放信息
            self.configPlayingInfo();
        }
    }
    var currentSongIndex = 0
    var isPlaying = false
    var timer : NSTimer!
    var totalTimeString = ""
    
    struct Constants {
        static let GETSONGTLISTTYPE = "n"
        static let SKIPSONGTYPE = "s"
        static let DELETESONGTYPE = "b"
    }
    
    // MARK: override
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startPlay", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeChannel:", name: MJChannelManager.Constants.MJChannelViewControllerDidSelectChannelNotification, object: nil)
        
        self.setUp()
        self.loadPlayListWithType(MJPlayerViewController.Constants.GETSONGTLISTTYPE)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: local
    func setUp()
    {
        isPlaying = true
        picture.layer.cornerRadius = picture.bounds.size.width / 2.0
        println("\(picture.layer.cornerRadius)")
        picture.layer.masksToBounds = true
        
        pictureBlock.setBackgroundImage(UIImage(named: "albumBlock"), forState: UIControlState.Normal)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        
        let session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        session.setActive(true, error: nil)
    }
    
    func loadPlayListWithType(type : String)
    {
        MJFetcher.sharedManager.fetchPlaylistwithType(type, song: playingSong, passedTime: 0, channel: MJChannelManager.sharedManager.currentChannel!, successCompletion: {
            ( data ) in
            var list = data as! [MJSong]
            self.playList += list
            self.playingSong = self.playList[self.currentSongIndex]
            }, errorCompletion: {
                ( error ) in
                println("\(error)")
        })
    }
    
    func startPlay()
    {
        if currentSongIndex > (playList.count-1)
        {
            self.loadPlayListWithType("p")
        }else
        {
            playingSong = playList[currentSongIndex]
        }
    }
    
    func changeChannel(notification : NSNotification)
    {
        let userInfo = notification.userInfo as! Dictionary<String,MJChannel>
        let channel = userInfo["channel"]
        MJChannelManager.sharedManager.currentChannel = channel
        self.loadPlayListWithType(MJPlayerViewController.Constants.GETSONGTLISTTYPE)
    }
    
    func updateProgress()
    {
        //专辑图片旋转
        picture.transform = CGAffineTransformRotate(picture.transform, CGFloat(M_PI / 1440))
        
        if(!player.currentPlaybackTime.isNaN)
        {
            let t = Int(player.currentPlaybackTime)
            let currentTimeMinutes = t / 60 //as NSInteger
            let currentTimeSeconds = t % 60 //as NSInteger
            
            var currentTimeString : String!
            if (currentTimeSeconds < 10) {
                currentTimeString = "\(currentTimeMinutes):0\(currentTimeSeconds)"
            } else {
                currentTimeString = "\(currentTimeMinutes):\(currentTimeSeconds)"
            }
            
            var timerLabelString = "\(currentTimeString)/\(totalTimeString)"
            timerLabel.text = timerLabelString
            if playingSong != nil
            {
                timerProgressBar.progress = Float(player.currentPlaybackTime) / Float(playingSong!.length.toInt()!)
            }
        }
    }
    
    func addHeartSongToUser(user : MJUserInfo, song : MJSong, action : String)
    {
        MJFetcher.sharedManager.addHeartSongToUser(user, song: song, action: action, successCompletion: {
            (data) in
                println("添加红心：\(action)")
            }, errorCompletion: {
            (error) in
                println("\(error)")
        })
    }
    
    // MARK: IBAction
    
    @IBAction func pauseBtnTapped() {
        println("---")
        if (isPlaying) {
            player.pause()
            picture.alpha = 0.2
            pictureBlock.setBackgroundImage(UIImage(named: "albumBlock2"), forState: UIControlState.Normal)
            pauseBtn.setBackgroundImage(UIImage(named: "play"), forState: UIControlState.Normal)
            timer.fireDate = NSDate.distantFuture() as! NSDate
        } else {
            player.play()
            picture.alpha = 1.0
            pictureBlock.setBackgroundImage(UIImage(named: "albumBlock"), forState: UIControlState.Normal)
            pauseBtn.setBackgroundImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            timer.fireDate = NSDate()
        }
        isPlaying = !isPlaying
    }
    
    @IBAction func likeBtnTapped() {
        let user = MJUserInfoManager.sharedManager.userInfo
        if user.cookies == ""
        {
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = "还没有登录，赶紧登录哦！"
            hud.margin = 10
            hud.removeFromSuperViewOnHide = true
            
            hud.hide(true, afterDelay: 3)
            return
        }
        
        if playingSong?.like.toInt() == 0
        {
            playingSong?.like = "1"
            likeBtn.setBackgroundImage(UIImage(named: "heart2"), forState: UIControlState.Normal)
            self.addHeartSongToUser(user, song: playingSong!, action: "y")
        }else
        {
            playingSong!.like = "0"
            likeBtn.setBackgroundImage(UIImage(named: "heart1"), forState: UIControlState.Normal)
            self.addHeartSongToUser(user, song: playingSong!, action: "n")
        }
    }
    
    @IBAction func deleteBtnTapped(){
        if (!isPlaying) {
            player.play()
            isPlaying = true
            picture.alpha = 1.0
            pictureBlock.setBackgroundImage(UIImage(named: "albumBlock"), forState: UIControlState.Normal)
            pauseBtn.setBackgroundImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
        self.loadPlayListWithType(MJPlayerViewController.Constants.DELETESONGTYPE)
    }
    
    @IBAction func nextBtnTapped(){
        timer.fireDate = NSDate.distantFuture() as! NSDate
        player.pause()
        if (!isPlaying) {
            picture.alpha = 1.0
            pictureBlock.setBackgroundImage(UIImage(named: "albumBlock"), forState: UIControlState.Normal)
        }
        self.loadPlayListWithType(MJPlayerViewController.Constants.SKIPSONGTYPE)
    }
    
    // MARK: Remote Control
    
    func configPlayingInfo()
    {
        if NSClassFromString("MPNowPlayingInfoCenter") != nil
        {
            if playingSong!.title != ""
            {
                var dict = [NSObject : AnyObject]()
                dict[MPMediaItemPropertyTitle] = playingSong!.title
                dict[MPMediaItemPropertyArtist] = playingSong!.artist
                dict[MPMediaItemPropertyPlaybackDuration] = NSNumber(float: (playingSong!.length as NSString).floatValue)
                
                let posterImage = UIImage.loadImageWithUrl(playingSong!.picture)
                if (posterImage != nil)
                {
                    dict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: posterImage)
                }
                
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = dict
            }
        }
    }
    
    //添加播放控制器（Remote Control Events）
    override func remoteControlReceivedWithEvent(event : UIEvent)
    {
        if event.type == UIEventType.RemoteControl
        {
            switch(event.subtype)
            {
            case UIEventSubtype.RemoteControlPause, UIEventSubtype.RemoteControlPlay:
                pauseBtnTapped()
            case UIEventSubtype.RemoteControlNextTrack:
                self.nextBtnTapped()
            default:
                break
            }
        }
    }
}