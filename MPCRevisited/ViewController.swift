//
//  ViewController.swift
//  MPCRevisited
//
//  Created by NL33 on 3/5/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblPeers: UITableView!  //part of setup code
    
    //*(3)* DISPLAYING FOUND PEERS. continued from appdelegate (11) after MPCManager.swift (10). Start here at (12)
    
    //(12)
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate  //declare and instantiate an application delegate object (both at the same time (new feature of swift to do both at same time).
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblPeers.delegate = self  //part of setup code
        
        tblPeers.dataSource = self  //part of setup code
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: IBAction method implementation
    
    @IBAction func startStopAdvertising(sender: AnyObject) {
        
    }
    
    
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 //part of setup code
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0; //part of setup code
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0.0 //part of setup code
    }
    
}

