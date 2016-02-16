//
//  TwitterClient.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/13.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let consumerKey = "Suie3UEpH5lC6aVrVR9nGpJl8"
let consumerSecret="qajP6sifOd4pSj14ekKNAseLAwj43zoB1GkOHiDr5DqFkYHjf5"
let TwitterURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    var loginCompletion:((user:User?, error: NSError?) ->())?
    
    class var sharedInstance: TwitterClient{
        struct Static {
            static let instance = TwitterClient(baseURL: TwitterURL, consumerKey: consumerKey, consumerSecret: consumerSecret)
        }
        
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user:User?, error: NSError?) ->()){
        loginCompletion = completion
        
        //fetch request token
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "Lightpostlls://oauth"), scope: nil, success: { (requestToken:BDBOAuth1Credential!) -> Void in
            print("Got request token")
            let authURL=NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            
            UIApplication.sharedApplication().openURL(authURL!)
            
            }) { (error:NSError!) -> Void in
                print("Failed to get request token")
                
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url:NSURL){
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken:BDBOAuth1Credential!) -> Void in
            print("Got access toke")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation:NSURLSessionDataTask!, response:AnyObject?) -> Void in
                print("user:\(response)")
                
                var user = User(dictionary: response as! NSDictionary)
                print("user:\(user.name)")
                
                self.loginCompletion?(user: user, error: nil)
                
                }, failure: { (operation:NSURLSessionDataTask?, error:NSError) -> Void in
                    print("error")
                    self.loginCompletion?(user: nil, error: error)
                    
            })
            
            TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: nil, success: { (operation:NSURLSessionDataTask!, response:AnyObject?) -> Void in
                //print("home timeline:\(response)")
                
                var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                for tweet in tweets{
                    print("text:\(tweet.text), created:\(tweet.createAt)")
                }
                }, failure: { (operation:NSURLSessionDataTask?, error:NSError) -> Void in
                    print("error")
                    
                    
            })
            
            }) { (error:NSError!) -> Void in
                print("fail to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}
