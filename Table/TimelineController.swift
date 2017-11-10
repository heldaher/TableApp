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
    let container = CKContainer.default()
    var userName: String?
    var date: Date?
    
    //let db = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserName()
        loadPosts()
    }
    
    func checkIfFirstTimeUser() {
        //check if user has never logged on before
        //how? get ckredord id and loop through existing user base to see
        //see if can make user - need to look up this class
        //if not first time user, then call 'createUser() mthod
    }
    
    func createUser() {
        //newAuthor = ... (use code from other file
        //then in other file will need to assign a new post to the current user
        //above may be tricky
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
                        self.container.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userInfo, error) in
                            if error != nil {
                                print("handle other error")
                            } else {
                                self.userName = (userInfo?.nameComponents?.givenName)! + " " + (userInfo?.nameComponents?.familyName)! as String
                                //print("CK User Name: " + self.userName!)
                                //print("\(self.givenName)")
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
        
            if let postAuthor = post["poster"] as? CKReference {
                //print ("\(postAuthor.recordID)")
                let authorID = postAuthor.recordID
                let db = container.publicCloudDatabase
                db.fetch(withRecordID: authorID, completionHandler: { (record, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        //not sure why this code seems to run twice
                        print("ok!")
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

}
