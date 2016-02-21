//
//  TweetsViewController.swift
//  Lightpost
//
//  Created by 吕凌晟 on 16/2/16.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import Foundation


let expandingCellId = "expandingCell"
let estimatedHeight: CGFloat = 200
let topInset: CGFloat = 20
var tablesize : NSInteger = 20

class TweetsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var params=["count" : "100"]
    
    var tweets:[Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
            self.tweets=tweets
            self.tableView.reloadData()
            print(tweets?.count)
            //print(tweets![0].text)
            //print(tweets![0].user?.name)
            //print(tweets![0].user?.profilelargeImageURL)
            
        }
        
        
        tableView.delegate=self
        tableView.dataSource=self
        

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tweets != nil {
            return tablesize
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetsCell", forIndexPath: indexPath) as! TweetsCell
        
//        print(indexPath.row)
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if let selectedIndex = tableView.indexPathForSelectedRow where selectedIndex == indexPath {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetsCell
            tableView.beginUpdates()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            cell.changeCellStatus(false)
            tableView.endUpdates()
            
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetsCell
        cell.changeCellStatus(true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func onLogout(sender: AnyObject) {
        
        User.currentUser?.logout()
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
    
    func loadMoreData() {
        

            
            self.isMoreDataLoading = false
            tablesize=tablesize+20
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
            //print(tweets?.count)
            //print(tweets![0].text)
            //print(tweets![0].user?.name)
            //print(tweets![0].user?.profilelargeImageURL)

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // Code to load more results
                NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "loadMoreData", userInfo: nil, repeats: false)
                //loadMoreData()
            }
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
            self.tweets=tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            
            //print(tweets![0].text)
            //print(tweets![0].user?.name)
            //print(tweets![0].user?.profilelargeImageURL)
            
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

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}
