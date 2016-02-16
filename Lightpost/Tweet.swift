//
//  Tweet.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/14.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text:String?
    var createdAtString:String?
    var tagline: String?
    var createAt: NSDate?
    
    init(dictionary:NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) ->[Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in array{
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
