//
//  detailViewController.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/23.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import AFNetworking

class detailViewController: UIViewController{

   
    
    //var tweets:[Tweet]!
    //var tweet: Tweet!
    var index: Int!
    var didRetweet = false
    var didTouchFavourite = false
    var tweetId: Int!
    var original_tweet_id : Int!
    var original_tweet :NSDictionary!
    var retweet_id : Int!
    var avatarURL : NSURL!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var commentTable: UITableView!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var reTweetButton: UIButton!
    
    var tweet:Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetId = tweet.id
        
        self.UserName.text = tweet.user?.name
        self.tweetText.text = tweet.text
        // Do any additional setup after loading the view.
        
        self.didRetweet=false
        self.didTouchFavourite = tweet.didfav!
        
        if(tweet.didretweeted == true){
            self.reTweetButton.setImage(UIImage(named: "retweet-action-on-green"), forState: .Normal)
        }else{
            self.reTweetButton.setImage(UIImage(named: "retweet-action_default"), forState: .Normal)
        }
        
        if(tweet.didfav == true){
            self.favButton.setImage(UIImage(named: "like-action-on-red"), forState: .Normal)
        }else{
            self.favButton.setImage(UIImage(named: "like-action-off"), forState: .Normal)
        }

        let tempurlstring = tweet.user?.profilelargeImageURL!
        
        avatarURL = NSURL(string: tempurlstring!)
        print(tempurlstring)
        print("URL: \(avatarURL)")
        userAvatar.setImageWithURL(avatarURL)
        self.userAvatar.layer.cornerRadius=25
        
        self.userAvatar.layer.masksToBounds=true
        self.userAvatar.layer.borderColor = UIColor(white: 0.5, alpha: 0.8).CGColor
        self.userAvatar.layer.borderWidth = 2
        // Do any additional setup after loading the view.

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(commentTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentTable.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        return cell
    }
    
    func tableView(commentTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }


    @IBAction func onFav(sender: AnyObject) {
        if !didTouchFavourite {
            //call favourite
            TwitterClient.sharedInstance.favoriteStatus(tweetId) { errror in
                let temptweet = self.tweet
                self.didTouchFavourite = true
                temptweet.favNumber! += 1
                self.favButton.setImage(UIImage(named: "like-action-on-red"), forState: .Normal)
                temptweet.didfav=true
                self.tweet=temptweet
                
            }
        } else {
            //call unfavouriteStatus
            TwitterClient.sharedInstance.unfavoriteStatus(tweetId) { error in
                let temptweet = self.tweet
                self.didTouchFavourite = false
                temptweet.favNumber! -= 1
                self.favButton.setImage(UIImage(named: "like-action-off"), forState: .Normal)
                temptweet.didfav=false
                self.tweet=temptweet
            }
        }
        
    }
    @IBAction func onRetweet(sender: AnyObject) {
        
        if !didRetweet {
            //perform retweet logics
            TwitterClient.sharedInstance.retweetStatus(tweetId) { error in
                let temptweet = self.tweet
                temptweet.RetweetNumber! += 1
                self.reTweetButton.setImage(UIImage(named: "retweet-action-on-green"), forState: .Normal)
                self.didRetweet = true
                temptweet.didretweeted=true
                self.tweet = temptweet
            }
        } else {
            // step 1
            if(didRetweet==false){
                print("Haved retweeted yet")
            }
                // you cannot unretweet a tweet that has not retweeted
            else if (tweet.retweetedstatus == nil){
                original_tweet_id = tweet.id
            }else{ // tweet was itself a retweet
                original_tweet_id = tweet.retweetedstatus!["id"] as! Int
                //print(tweet.retweetedstatus)
                //print(original_tweet_id)
            }
            
            // step 2
            
            TwitterClient.sharedInstance.showStatus(original_tweet_id!, completion: { (status, error) -> () in
                self.original_tweet = status
                print(self.original_tweet["current_user_retweet"]!["id"])
                self.retweet_id = self.original_tweet["current_user_retweet"]!["id"] as! Int
                print(self.retweet_id)
                
                TwitterClient.sharedInstance.unretweetStatus(self.retweet_id, completion: { (error) -> () in
                    let temptweet = self.tweet
                    temptweet.RetweetNumber! -= 1
                    self.reTweetButton.setImage(UIImage(named: "retweet-action_default"), forState: .Normal)
                    self.didRetweet = false
                    temptweet.didretweeted=false
                    self.tweet = temptweet
                })
            })
            
            //let retweet_id = full_tweet.current_user_retweet.id_str
            
            // step 3
            //POST("https://api.twitter.com/1.1/statuses/destroy/" + retweet_id + ".json")
            
            
            //un retweet, if successful, decrement
            
            
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
