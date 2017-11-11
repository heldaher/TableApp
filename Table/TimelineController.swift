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
    
    var posts = [CKRecord]()
    var users = [CKRecord]()
    let container = CKContainer.default()
    var userName: String?
    var userRecordID: CKRecordID?
    var date: Date?
    
    var isExistingUser = false
    var user: CKRecord?
    
    //let db = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        loadPosts()
        fetchUsers()
    }
    
    func checkIfFirstTimeUser() {
        //check if user has never logged on before
        //how? get ckredord id and loop through existing user base to see
        //print(userRecordID!)
        //with above have userRecordID
        //now need to loop thorugh existing user base
        //so need to fetch all users (before then looping through
        //so need to create a fetchUsers function

        //need to check if current user (based on getUserName) exists in users array
        //issue is that the current user's record id does not match the existing user's record ids?
        //why? if i have the same info shouldn't it be the same recordid
        //or i guess a different one is made each time?
        
        //<CKRecordID: 0x60000003cf00; recordName=_c286ece40a902a4ad2b3058a56e691d1, zoneID=_defaultZone:__defaultOwner__>
        //<CKRecordID: 0x60800003ff00; recordName=C25510DD-CDE4-4C76-8687-8388A711EC07, zoneID=_defaultZone:__defaultOwner__>
        //why is post not showing up?

        for user in users {
            if user["CKID"]! as! String == userRecordID!.recordName {
            //if user.recordID.recordName == userRecordID!.recordName {
                //print("Got it")
                isExistingUser = true
                self.user = user
                return
            } else {
                print("don't got it")
            }
        }
        
        if isExistingUser == false {
            createUser()
        }
        
        //authors[0].recordID
        
        //see if can make user - need to look up this class
        //if not first time user, then call 'createUser() mthod
    }
    
    func fetchUsers() {
        users = [CKRecord]()
        
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let users = results {
                self.users = users
            }
        }
    }
    
    func createUser() {
        //newAuthor = ... (use code from other file)
        //then in other file will need to assign a new post to the current user
        //above may be tricky
        let newUser = CKRecord(recordType: "User")
        newUser["name"] = self.userName! as NSString
        newUser["CKID"] = self.userRecordID!.recordName as NSString
        
        let db = container.publicCloudDatabase
        
        db.save(newUser, completionHandler: { (record, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("user saved")
                self.user = record
            }
        })
    }
    
    //<CKRecordID: 0x604000025d20; recordName=_c286ece40a902a4ad2b3058a56e691d1, zoneID=_defaultZone:__defaultOwner__>
    
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
                                //print("CK User Name: " + self.userName!)
                                //print("\(self.givenName)")
                                
                                //self.userRecordID = userInfo!.userRecordID
                                self.checkIfFirstTimeUser()
                                //self.createUser()
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func loadPosts() {
        posts = [CKRecord]()

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








