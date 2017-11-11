//
//  CreateGroupController.swift
//  Table
//
//  Created by Henri El Daher on 11/11/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class CreateGroupController: UIViewController {
    
    let container = CKContainer.default()
    var group: CKRecord?
    
    @IBOutlet weak var groupName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if groupName.text! != "" {
            let newGroup = CKRecord(recordType: "Group")
            newGroup["name"] = groupName.text! as NSString
        
            let db = container.publicCloudDatabase
            
            db.save(newGroup, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("group saved")
                }
            })
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
