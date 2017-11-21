//
//  GroupMembersController.swift
//  Table
//
//  Created by Henri El Daher on 11/18/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class GroupMembersController: UITableViewController {
    
    //check why this won't work (table won't load)
    
    let container = CKContainer.default()
    var group: CKRecord!
    var users = [CKRecord]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(group!["name"]!)"
        fetchGroupMembers()
    }
    
    func fetchGroupMembers() {
        users = [CKRecord]()
        
        let db = container.publicCloudDatabase
        let reference = CKReference(recordID: group.recordID, action: .none)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "groups", reference)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        db.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                if let users = results {
                    self.users = users
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
        })
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
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath)
        
        let user = users[indexPath.row]
        let usernameLabel = cell.viewWithTag(5000) as! UILabel
        usernameLabel.text = user["name"] as? String

        return cell
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
