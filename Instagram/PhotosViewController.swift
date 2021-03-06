//
//  PhotosViewController.swift
//  Instagram
//
//  Created by Quyen Quyen Mac on 1/26/16.
//  Copyright © 2016 Quyen Mac. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    //var photos: [NSDictionary]?
    var photos: [NSDictionary]! = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.title = "Instagram"

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 320
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.photos = responseDictionary["data"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
        /*if let photos = photos {
            return photos.count
        }
        else {
            return 0
        }*/
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        let photo = photos![indexPath.section]
        
        let photoPath = photo.valueForKeyPath("images.low_resolution.url") as! String
        
        let imageUrl = NSURL(string: photoPath)
        
        cell.photoView.setImageWithURL(imageUrl!)
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // get username and profile picture from api
        let photo = photos[section]
        let user = photo["user"] as! NSDictionary
        let username = user["username"] as! String
        
        let profileUrl = NSURL(string: user["profile_picture"] as! String)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor.whiteColor()
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        
        profileView.setImageWithURL(profileUrl!)
        headerView.addSubview(profileView)
        
        let userLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 250, height: 30))
        userLabel.text = username;
        userLabel.textColor = UIColor.blueColor()
        userLabel.font = UIFont.boldSystemFontOfSize(15)
        
        headerView.addSubview(userLabel)
        
        return headerView;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return photos.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func onRefresh(refreshControl: UIRefreshControl)
    {
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url2 = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let myRequest = NSURLRequest(URL: url2!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.photos = responseDictionary["data"] as! [NSDictionary]
                            
                            self.tableView.reloadData()
                            
                            refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        let photo = photos![indexPath!.section]
        vc.photos = photos

    }
    

}
