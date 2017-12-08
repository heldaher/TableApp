//
//  TimelineController.swift
//  Table
//
//  Created by Henri El Daher on 11/6/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class TimelineController: UITableViewController {
    
    //need to figure out why it shouws different user upon builds (though should be ok for actual run)
    //need to figure it why it loads several times (though bad but fine for MVP)
    
    var posts = [CKRecord]()
    var users = [CKRecord]()
    var allGroups = [CKRecord]()
    var userGroups = [CKRecord]()
    var groupReferences = [CKReference]()
    let container = CKContainer.default()
    var userName: String?
    var userRecordID: CKRecordID?
    var date: Date?
    
    var isExistingUser = false
    var user: CKRecord?
    
    //let db = CKContainer.default().publicCloudDatabase
    @objc func refresh() {
        loadPosts()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        //getUserName()
        //maybe call load posts from getusername?
        //loadPosts()
    }
    
    //12/2 new code
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
    func fetchUsers() {
        users = [CKRecord]()
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let users = results {
                self.users = users
                //12/1 code below
                self.getUserName()
            }
        }
    }
    
    
    //note to self: will need to handle user denying permission, and let know necessay to use app
    func getUserName() {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if error != nil {
                print("permission error")
            } else {
                self.container.fetchUserRecordID { (recordId, error) in
                    if error != nil {
                        print("handle error")
                    } else {
                        self.userRecordID = recordId
                        self.container.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userInfo, error) in
                            if error != nil {
                                print("handle other error")
                            } else {
                                self.userName = (userInfo?.nameComponents?.givenName)! + " " + (userInfo?.nameComponents?.familyName)! as String
                                
                                //self.userRecordID = userInfo!.userRecordID
                                self.checkIfFirstTimeUser()
                                //self.createUser()
                                
                                /* 12/1 comment out
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                */
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func checkIfFirstTimeUser() {

        //comment out for in loop below and change user name to create mock user
        //note that there are some issues when create fake user first
        //issue I think is below code returns yes for first user created in array...
        
        for user in users {
            if user["CKID"]! as! String == userRecordID!.recordName {
            //if user.recordID.recordName == userRecordID!.recordName {
                //print("Got it")
                isExistingUser = true
                self.user = user
                //return
                
                //new 12/1 code
                loadPosts()
                return
            } else {
                print("don't got it")
            }
        }
        
        if isExistingUser == false {
            createUser()
        }

    }
    

    func createUser() {
        let newUser = CKRecord(recordType: "User")
        newUser["name"] = self.userName! as NSString
        
        //mock user code if want to create more mock users (comment above and uncomment below and above loop
        //newUser["name"] = "Bill Gates" as NSString

        newUser["CKID"] = self.userRecordID!.recordName as NSString
        newUser["checked"] = "false" as NSString
        //newUser["groups"] = [CKReference]() as NSArray
        //will add groups later somehow
        
        let db = container.publicCloudDatabase
        
        db.save(newUser, completionHandler: { (record, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("user saved")
                self.user = record
                
                //new 12/1 code
                self.loadPosts()
            }
        })
    }
    
    //before calling edited loadposts, will need to have the current user
    /*
    func loadPosts() {
        posts = [CKRecord]()

        //first get all the groups of the user
        //so will want a fetchGroups method
        //then once have list of groups:
        //loop through each post
        //during each post loop, loop through each reference:
        //during each groups reference loop, loop through the groups array and check if equal
        //if so, stop and append post to post array
        
        //above seems too much? see if there is a predicate for 'contains'
        let query = CKQuery(recordType: "Post", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let posts = results {
                self.posts = posts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    */
    
    //for each group in user["groups"], append to userGroups array
    func loadPosts() {
        //LIST_CONTAINS cannot be applied with filter value type REFERENCE_LIST
        posts = [CKRecord]()
        
        let db = container.publicCloudDatabase
        let groupReferences = user!["groups"]! as! NSArray
        //maybe want to loop each reference and then use reference/predicate code for GMC controller
        
        for group in groupReferences {
            let reference = group as! CKReference
            let predicate = NSPredicate(format: "%K CONTAINS %@", "groups", reference)
            let query = CKQuery(recordType: "Post", predicate: predicate)
            db.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
                if error != nil {
                    print (error!.localizedDescription)
                } else {
                    if let newPosts = results {
                        for newPost in newPosts {
                            if !self.posts.contains(where: { post in post.recordID.recordName == newPost.recordID.recordName}) {
                                self.posts.append(newPost)
                            }
                        }

                        /*
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        */
                        
                        self.showPosts()
                        
                    }
                }
                
            })
        }

        //showPosts()
    }
    
    func showPosts() {
        posts = posts.sorted(by: {$0.creationDate! > $1.creationDate!})
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timelineCell", for: indexPath)
        
        if posts.count == 0 {
            return cell
        }
        
        let post = posts[indexPath.row]
        if let postContent = post["content"] as? String {
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormat.string(from: post.creationDate!)
            
            let nameLabel = cell.viewWithTag(1001) as! UILabel
            let postLabel = cell.viewWithTag(1000) as! UILabel
            let dateLabel = cell.viewWithTag(1002) as! UILabel
            
            //need to figure out how to get author["name"] from post
            //know that post["poster"]! gives CKReference
            
            //nameLabel.text = " "
            postLabel.text = postContent
            dateLabel.text = dateString
        
            //note that postAuthor is a user
            if let postAuthor = post["poster"] as? CKReference {
                //print ("\(postAuthor.recordID)")
                let authorID = postAuthor.recordID
                let db = container.publicCloudDatabase
                db.fetch(withRecordID: authorID, completionHandler: { (record, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        //not sure why this code seems to run twice
                        //print("ok!")
                        if let record = record {
                            DispatchQueue.main.async {
                                nameLabel.text = record["name"]! as? String
                            }
                            
                        }
                    }
                })
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //newPost
        
        if segue.identifier == "newPost" {
            let controller = segue.destination as! NewPostController
            controller.user = user
            
        }
    }
    
    
    /*
     trying not to create a new author every time
     i.e., do not want 'user' and author', but just 'user' - these refer to the same thing
     if I make two posts, I don't want 2 authors created
     
     I want an author or user to be created when I first log in,
     and to be identified when I log in from then on
     
     so first time I log in I want to create user
     newUser = CKRecord(type: "User")
     newUser["name"] = self.userName! (CKRecordID will automatically be created)
     
     BUT, only wnat to do this if new user
     otherwise, instead of creating a new user, want to identify and fetch new user
     How?
     check current user's info against stored existing users
     check current user's record id against stored existing users' recordIDs
     BUT
     how can existing users have stored recordIDs if can't assing them one? BECAUSE they are automatically created and accessible
    */

}








