//
//  MyGroupsController.swift
//  Table
//
//  Created by Henri El Daher on 11/16/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class MyGroupsController: UITableViewController {
    
    //need to figure out back button
    //need to decide whether to click on group name, or see "X members" and click on that (leaning towards latter)

    let container = CKContainer.default()
    var groups = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGroups()
    }
    
    func fetchGroups() {
        groups = [CKRecord]()
        
        let query = CKQuery(recordType: "Group", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if let groups = results {
                self.groups = groups
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("\(groups.count)")
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupNameCell", for: indexPath)
        let label = cell.viewWithTag(3001) as! UILabel
        
        let group = groups[indexPath.row]
        
        if let groupName = group["name"] as? String {
            
            label.text = groupName
        }

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
