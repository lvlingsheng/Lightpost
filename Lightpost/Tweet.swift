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
    var id: Int?
    var text:String?
    var createdAtString:String?
    var tagline: String?
    var createAt: NSDate?
    var favNumber :Int?
    var RetweetNumber :Int?
    var didfav :Bool?
    var didretweeted: Bool?
    var retweetedstatus : NSDictionary?
    
    init(dictionary:NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        id = dictionary["id"]! as? Int
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createAt = formatter.dateFromString(createdAtString!)
        favNumber = dictionary["favorite_count"] as? Int
        RetweetNumber = dictionary["retweet_count"] as? Int
        didfav = dictionary["favorited"] as? Bool
        didretweeted = dictionary["retweeted"] as? Bool
        retweetedstatus = dictionary["retweeted_status"] as? NSDictionary
    }
    
    class func tweetsWithArray(array: [NSDictionary]) ->[Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in array{
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
