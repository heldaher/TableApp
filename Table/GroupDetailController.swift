//
//  GroupDetailController.swift
//  Table
//
//  Created by Henri El Daher on 11/19/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class GroupDetailController: UITableViewController {
    
    //3) List timeline just of posts to the group (right now showing all posts
    //3A) this will mean 'NewPost' screen will need to allow user to specify which groups receive which posts
    
    //4) Connect plus button to new post just for that group
    
    var group: CKRecord!
    var posts = [CKRecord]()
    let container = CKContainer.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(group!["name"]!)"
        loadPosts()
    }
    
    /*
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
    */
    
    func loadPosts() {
        //LIST_CONTAINS cannot be applied with filter value type REFERENCE_LIST
        posts = [CKRecord]()
        
        let db = container.publicCloudDatabase
        let reference = CKReference(recordID: group.recordID, action: .none)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "groups", reference)
        let query = CKQuery(recordType: "Post", predicate: predicate)
        
        db.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                if let posts = results {
                    self.posts = posts
                    
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
    
    func showPosts() {
        posts = posts.sorted(by: {$0.creationDate! > $1.creationDate!})
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTimelineCell", for: indexPath)
        
        if posts.count == 0 {
            return cell
        }
        
        let post = posts[indexPath.row]
        if let postContent = post["content"] as? String {
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormat.string(from: post.creationDate!)
            
            let nameLabel = cell.viewWithTag(4001) as! UILabel
            let postLabel = cell.viewWithTag(4000) as! UILabel
            let dateLabel = cell.viewWithTag(4002) as! UILabel
            
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
