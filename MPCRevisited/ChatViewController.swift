//
//  ChatViewController.swift
//  MPCRevisited
//
//  Created by NL33 on 3/6/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtChat: UITextField! //initial app set up
    
    @IBOutlet weak var tblChat: UITableView! //initial app setup
    
//(27) Initialize the message array (the datasource of the tableview)(coming here after MPCManager.swift)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblChat.delegate = self //initial app set up
        tblChat.dataSource = self //initial app set up
        
        tblChat.estimatedRowHeight = 60.0 //initial app set up
        tblChat.rowHeight = UITableViewAutomaticDimension //initial app setup

        txtChat.delegate = self //initial app set up
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
        
    }
    
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 //initial app set up
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0; //initial app setup
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
