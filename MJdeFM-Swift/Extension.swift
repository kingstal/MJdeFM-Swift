//
//  UIImageExtension.swift
//  MJdeFM-Swift
//
//  Created by WangMinjun on 15/8/8.
//  Copyright (c) 2015年 WangMinjun. All rights reserved.
//

import Foundation

extension UIImage
{
    class func loadImageWithUrl(url : String) -> UIImage?
    {
        let data  = NSData(contentsOfURL: NSURL(string: url)!)
        let posterImage = UIImage(data: data!)
        return posterImage
    }
}

extension NSString
{
    class func getDocumentPath() -> String {
    return  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }
}
