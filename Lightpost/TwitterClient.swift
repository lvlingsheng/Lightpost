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

    
    /**
     Function to load hometimeLine
     
     - parameter params:     The parameters for the GET: It is a NSDictionary
     - parameter completion:  return [Tweets] if no error
     */
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) ->()){
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation:NSURLSessionDataTask!, response:AnyObject?) -> Void in
            //print("home timeline:\(response)")
            
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error:nil)
            }, failure: { (operation:NSURLSessionDataTask?, error:NSError) -> Void in
                print("error getting homeTimeline")
                completion(tweets: nil, error: error)
                
                
        })
    }
    
    
    func showStatus(original_tweet_id:Int?, completion: (status: NSDictionary?, error: NSError?) -> ()) {
     
        GET("1.1/statuses/show/\(original_tweet_id!).json?include_my_retweet=1", parameters: nil, success: { (operation:NSURLSessionDataTask!, response:AnyObject?) -> Void in
            print(response)
            let originaltweets = response as! NSDictionary
            completion(status: originaltweets, error:nil)
            }, failure: { (operation:NSURLSessionDataTask?, error:NSError) -> Void in
                print("error getting homeTimeline")
                completion(status: nil, error: error)
                
                
        })
    }
    
    func favoriteStatus(tweetID: Int, completion: (error: NSError?) -> ()) {
        POST("/1.1/favorites/create.json", parameters: ["id": tweetID], success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion(error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, err: NSError!) -> Void in
                completion(error: err)
        })
    }
    
    
    func unfavoriteStatus(tweetID: Int, completion: (error: NSError?) -> ()) {
        POST("/1.1/favorites/destroy.json", parameters: ["id": tweetID], success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion(error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, err: NSError!) -> Void in
                completion(error: err)
        })
    }
    
    
    func retweetStatus(tweetID: Int, completion: (retweetedTweetID: Int?, error: NSError?) -> ()) {
        POST("/1.1/statuses/retweet/\(String(tweetID)).json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //let tweetArray = Tweet.tweetsfromJSON(JSON(response))
            print(response)
            //completion(retweetedTweetID: tweetArray.first?.tweetID, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, err: NSError!) -> Void in
                completion(retweetedTweetID: nil, error: err)
        })
    }
    
    
    func unretweetStatus(retweetedTweetID: Int, completion: (error: NSError?) -> ()) {
        POST("/1.1/statuses/destroy/\(retweetedTweetID).json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion(error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, err: NSError!) -> Void in
                completion(error: err)
        })
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
                
                let user = User(dictionary: response as! NSDictionary)
                
                
                User.currentUser=user
                print("user:\(user.name)")
                
                self.loginCompletion?(user: user, error: nil)
                
                }, failure: { (operation:NSURLSessionDataTask?, error:NSError) -> Void in
                    print("error")
                    self.loginCompletion?(user: nil, error: error)
                    
            })
            

            
            }) { (error:NSError!) -> Void in
                print("fail to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}
