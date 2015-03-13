//
//  ChatViewController.swift
//  MPCRevisited
//
//  Created by NL33 on 3/6/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit
import MultipeerConnectivity //(30) required to fix error in Xcode caused by textfieldshouldreturn method.

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtChat: UITextField! //initial app set up
    
    @IBOutlet weak var tblChat: UITableView! //initial app setup
    
//(27) Initialize the message array that will hold the messages between peers. (the datasource of the tableview)(coming here after MPCManager.swift)
    var messagesArray: [Dictionary<String, String>] = [] //The array will be the datasource of the tableview. Each object in the array is going to be a dictionary with a string key and a string value. We create a dictionary because we need to have a pair of data for each message sent or received: the sender (author) of the message and the message itself. When our device is the one sending the message (when we’re the authors) then the self value will be set as the sender of the message in our device, while our peer display name will be sent to the other device.
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate  //we declare and instantiate an application delegate object, so we can access the mpcManager property of the AppDelegate class.
 //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblChat.delegate = self //initial app set up
        tblChat.dataSource = self //initial app set up

        //(33) NOTE: we here use self sizing cells. So, the cell size is dynamic, as we do not know the length of the messages that will be in the cells. (for more, see: http://www.appcoda.com/self-sizing-cells/) . To do this, we set the number of lines in the cell's text label to zero (see step (29), and then here we set these two properties (iOS takes care of the rest):
        
        tblChat.estimatedRowHeight = 60.0 //initial app set up
        tblChat.rowHeight = UITableViewAutomaticDimension //initial app setup
//
    //*7* RECEIVING DATA. got to MPCManager.swiftfile to implement new method for Receiving Data. Start at (34)
        
        txtChat.delegate = self //initial app set up.  The ChatViewController class has already been set as the delegate of the text field.
        
    //(35) observe the notification we just set in the MPCManager.swift, so every time new data is received a notification will be posted:
        
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
    //
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
    
  //*8* END CHATTING.  Start at (37)
 //(37) add bar button to chat view controller, called End Chat. Connect to ibaction endChat Use this action to send a message to the other peer telling that the chat is over, and then dismiss view controller.
    @IBAction func endChat(sender: AnyObject) {
        let messageDictionary: [String: String] = ["message": "_end_chat_"]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as MCPeerID){
            self.dismissViewControllerAnimated(true, completion: { () -> Void in //dismiss the peer, then disconnect from the session:
                self.appDelegate.mpcManager.session.disconnect()
            })
        }
    }
  
   
    
    
    // MARK: UITableView related method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 //initial app set up
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//(31) make the number of rows in the table match the total objects existing in the messagesArray:
        return messagesArray.count
//
    }
    
 //(32) check who the sender of the message is. If the sender's value is the self value, then we will set the purple color to the subtitle label and we will display the message: "I said". In the opposite case, we will display the orange color and display the message "X said:", where X is the display name of the other peer:
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCell") as UITableViewCell
        
        let currentMessage = messagesArray[indexPath.row] as Dictionary<String, String>
        
        if let sender = currentMessage["sender"] {
            var senderLabelText: String
            var senderColor: UIColor
            
            if sender == "self"{
                senderLabelText = "I said:"
                senderColor = UIColor.purpleColor()
            }
            else{
                senderLabelText = sender + " said:"
                senderColor = UIColor.orangeColor()
            }
            
            cell.detailTextLabel?.text = senderLabelText
            cell.detailTextLabel?.textColor = senderColor
        }
        
        if let message = currentMessage["message"] {
            cell.textLabel?.text = message
        }
        
        return cell
    }
//
    
    //(28) call the method from step 26 (in the MPCManager.swift for sending data
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let messageDictionary: [String: String] = ["message": textField.text]
        
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: //here, we call the custom sendData method with the messageDictionary
            
            appDelegate.mpcManager.session.connectedPeers[0] as MCPeerID){ //here, we specify the target peer. Specifically, the MCSession class contains an array property named ConnectedPeers, to which all the peers connected to our device are added. In our implementation, we know that only one peer will be connected to the session, so its safe to access it directly using the first index of the array.
            
            var dictionary: [String: String] = ["sender": "self", "message": textField.text] //if data successfully sent, then we prepare a new dictionary with the sender and the message. The self value is set as the sender (as this is our message). Then using the append method of the messagesArray we add the dictionary to the array:
            messagesArray.append(dictionary)
            
            self.updateTableview() //we call this method to update the tableview. This updateTableview() is a custom method, implemented below
        }
        else{
            println("Could not send data")
        }
        
        textField.text = ""  //at the end of the data send, we clear the text field.
        
        return true
    }
    
    //(29) Implement the custom updateTableview method: point is to reload the tablveview data, so any new message will be displayed there, and to automatically scroll to the end of the tableview, so the most recent message will be visible:
    func updateTableview(){
        tblChat.reloadData()
        
        if self.tblChat.contentSize.height > self.tblChat.frame.size.height {
            tblChat.scrollToRowAtIndexPath(NSIndexPath(forRow: messagesArray.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true) //i the height of the tableve's content size becomes greater than the height of the tableview's frame, then we must scroll. We do so by the method you see above.
        }
    }

//(36) Implement the custom message, which will occur when the notification arrives, and the app will display to the tableview. Here is overview:
/*
--Initially, we’ll get the dictionary posted along with the notification, and we’ll “extract” the data and the peer contained in it.
--We’ll convert the data object to a Dictionary, so we can access the message.
--At this point, we’ll make a convention, and we’ll agree to a special phrase that means the end of chat. This phrase will be the “end_chat“ message.
--If the message is other than the above special value, then we’ll create a new dictionary containing the sender’s display name and the message. This dictionary will be added to the messagesArray array. Also, we will update the tableview.
--If the message signals the end of chat, then we’ll show an alert to the user letting him know that the other peer ended the chat, and we’ll dismiss the view controller. We’ll write the code for this step in the next part.
*/
    
func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["message"] {
            // Make sure that the message is other than "_end_chat_".
            if message != "_end_chat_"{
                // Create a new dictionary and set the sender and the received message to it.
                var messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                
                // Add this dictionary to the messagesArray array.
                messagesArray.append(messageDictionary)
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.updateTableview()
                })
            }
            else{
            //
            //(38) Add code for if an end chat message is received: display an alert controller to the user notifying him that the other peer ended the chat. Then disconnect from the session:
                // In this case an "_end_chat_" message was received.
                // Show an alert view to the user.
                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.appDelegate.mpcManager.session.disconnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
}
//(39) Should also handle end of chat becuase the other peer just terminates the application, or otherwise the connetion is lost. Post a new notification from the browser(browser:lostPeer:) delegate method in the MPCManager.swift file. Then observe for it and handle, similarly to the above notification. [Not implemented as part of tutorial]

//*9* FINISHING TOUCHES
