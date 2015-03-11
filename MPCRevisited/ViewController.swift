//
//  ViewController.swift
//  MPCRevisited
//
//  Created by NL33 on 3/5/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit
import MultipeerConnectivity  //(15) import multipeer connectivity

//(14) add the MPCManagerDelegat to the viewcontroller here to adopt the MPCManagerDelegate protocol:
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tblPeers: UITableView!  //part of setup code
   
    //(18) declare a Boolean property to check if the device is advertising or not (true means the device is advertising)
    var isAdvertising: Bool!
    //
    
    //*(3)* DISPLAYING FOUND PEERS. continued from appdelegate (11) after MPCManager.swift (10). Start here at (12)
    
    //(12)
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate  //declare and instantiate an application delegate object (both at the same time (new feature of swift to do both at same time)).
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblPeers.delegate = self  //part of setup code
        
        tblPeers.dataSource = self  //part of setup code
        
        //(13) set the ViewController as the delegate of the MPCManager class:
        appDelegate.mpcManager.delegate = self
        //
        
        //(14) start browsing for peers. We put in viewDidLoad so it occurs right after the app gets launched. Note that if want to stop the browser, can make a callto the stopBrowsingForPeers() method of the brower.
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        //
        
        //(17) Turn on advertising feature. And then set value for isadvertising to true, so device is advertising itself.
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        
        isAdvertising = true
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: IBAction method implementation
    
    //*(4)* HANDLING ADVERTISING. Start at (15)
    //(15) Create bar button on the ViewController. (I have labeled "Start/Stop*), which will toggle the advertisitng functionality. We will be creating an action sheet when the button is tapped.  In the action sheet, two buttons are going to exist: one to swithc between the two advertising states, and one to cancel and close the action sheet dialogue. The first button title will get changed depending on the current state. 
    
       //(15) continued...Create IBaction from it, called startStop Advertising
    let visibilityAction: UIAlertAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
       //
        /*(19) Implement the advertising action method:
       -- Firstly, we initialize an action sheet controller by providing it with a message and the proper style.
        --Next, depending on the current value of the isAdvertising variable, we specify the title for the first button of the action sheet by assigning the proper value to the actionTitle local variable.
        --By having the correct title, we create a new alert action which will be triggered when the user will tap in the first button.
        --The most important part is here: Based on the value of the isAdvertising variable, we either stop or start the advertising of the device. Of course, don’t forget to set the exact opposing value to the isAdvertising variable.
        --We create an (empty) action for the cancel button.
            Both of the actions are added to the action sheet controller.
        --Finally, the action sheet controller is presented animated to the view.
    */
        
        if self.isAdvertising == true {
            self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        }
        else{
            self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        }
        
        self.isAdvertising = !self.isAdvertising
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
        
    }


    actionSheet.addAction(visibilityAction)
    actionSheet.addAction(cancelAction)
    
    self.presentViewController(actionSheet, animated: true, completion: nil)
    //
}





    // MARK: UITableView related method implementation

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 //part of setup code
    }
    
    //(14) Tell the tableview what the datasource is and modify so it displays the names of the nearby peers:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    //
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       //(16) display the name of each peer--access the display name of each peer in the foundPeers array:
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellPeer") as UITableViewCell
        
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        
        return cell
        //
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       //(17) Specify the height of each row:
        return 60.0
    //
    }

//*(5)* INVITING A PEER. start at (20)

//(20) Make the tableview respond when tapping on a peer.  Then, implement the didSelectRowatIndexPath delegate method, and send the invitation to the selected peer:
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
    
    appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
      /* explanation of the invitePeer method:
            --peerID: the peer to which we want to send the invitation
            --toSession: the session object that we initialized in the MPCManager class
            --**withContext: This paramater can be used if you want to send some extra data to the invited peer. Requires a NSData object
            --timeout: here we specify howmany seconds the inviter will be waiting for the other peer's answer. Default value is 30 seconds--here we set it to 20.
       */
}
//
//(21) ^^ALlow app to handle received information. Go to MPCManager.swift.

    //(15) Implement the foundPeer and lostPeer methods we set in the MPCManager.swift. Here, we just use them to refresh the tableview:
    func foundPeer() {
        tblPeers.reloadData()
    }
    
    
    func lostPeer() {
        tblPeers.reloadData()
    }

//
//(22) (*5*( CONTINUED FROM MPCMANAGER.swift  implement the invitation was received method:
func invitationWasReceived(fromPeer: String) {
    let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert) //if invitation was received, we alert the user that they have been invited to chat. We provide two options: accept or decline.
    
    let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
        self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
    }
    
    let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
        self.appDelegate.mpcManager.invitationHandler(false, nil)
    }
    
    alert.addAction(acceptAction)
    alert.addAction(declineAction)
    
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
//(23) Switch to MPCManager.swift to implement code for connecting to session

//(24) continued from MPCManager.swift. Implement the connectedwithpeer method:
//We start chatting right after the peers have connected to the session, so we only have to navigate to the chat view controller scene (segue to chatviewcontroller)
func connectedWithPeer(peerID: MCPeerID) {
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        self.performSegueWithIdentifier("idSegueChat", sender: self)
    }
}
//

