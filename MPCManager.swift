//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by NL33 on 3/6/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//
import UIKit

//*1*. INITIAL SETUP OF CLASS. Start at (1)
import MultipeerConnectivity //(1)

//(6) create a new protocol for implementing the delegation pattern. We declare the delegates that we will need in advance.
protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}
//


class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate { //(4) confrorm to specific MPC protocols with these 3 additional delegates//
   
    //(7) declare a delegate object in this class:
     var delegate: MPCManagerDelegate?
    //
    
    //(2) declare the objects of the MPC framework classes that we will use
   var peer: MCPeerID! //the peer is the MPC device
    
    var session: MCSession! //the session is the connection between 2 peers
    
    var browser: MCNearbyServiceBrowser! //this finds other devices and invites them to join a session
    
    var advertiser: MCNearbyServiceAdvertiser! //this advertises the device (meaning makes it visible to other users, and for accepting invitations from other peers for connecting to sessions.
   //

    //(3) two additional variables we will use:
    var foundPeers = [MCPeerID]()  //array to stores all the peers that the browser of a device will discover. Initialized on declaration, so no need to keep it nil.
    
    var invitationHandler: ((Bool, MCSession!)->Void)! //the invitation handler is used to reply to the peer that sent the invitation. The bool value indicates whether the invitation was accepted or not. The mcsession is the session object, in case of a positive answer.  Connected to advertiser function
   //

    //(5) Initialize all the MPC objects.
override init() {
    super.init()
    
    peer = MCPeerID(displayName: UIDevice.currentDevice().name) //this represents the device as seen by other all other nearby devices. It must be initialized first, as it is used by all other objects as a paramater. With initialization, it requires a displayname. This will be visible to other users, and can be any string. Here, we set the display name as the device name, but could set this to be something the user sets.  This uses the UIDevice class to access the name
    
    session = MCSession(peer: peer)  //initialized using the peer already specified
    session.delegate = self  //make the MPCManager class the delegate for this and the following.
    
    browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc") //The initializer of this object accepts two parameters: The first one is the peer. The second one is a value that can’t be changed after the initialization, and it regards the service type that the browser should browse for. In simple words, it uniquely identifies the application among others so the MPC knows what to search for, and the same service type value must be set to the advertiser as well below. Note for this value: (a) It mustn’t be longer than 15 characters, and (b) it can contain only lowercase ASCII characters, numbers and hyphens. In case you break any rule, an exception will be thrown at runtime and the app will crash.    
    browser.delegate = self
    
    advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc") //Notice that here we set the same service type value as before. The extra parameter existing here, named discoveryInfo, is a ****dictionary that can contain any kind of extra information you want to pass to the other peers upon discovery.*** Note that both keys and values of this dictionary must be strings. For simplicity reasons, we set this parameter to nil.    
    advertiser.delegate = self
}
//

//*2* BROWSE FOR PEERS. Start at (8)
//(8) Function called by MPC when a nearby peer is found (ie, when another device is discovered).
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        
        foundPeers.append(peerID) //add the found peer to the foundPeers array declared previously. We will use this array as the datasource of the tableview in the ViewController class, where we will list found peers. Once we do so, we make a call to the foundPeer delegate method of the MPCManagerDelegate protocol. This delegate method is implemented in the ViewController class, and in there we reload the tableview data so the newly found peer will be displayed to the user.
        
        delegate?.foundPeer()
    }
//
    
//(9) Remove the Peers that are no longer available (discoverable))
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) { //locate the peer that was lost in the foundPeers array, and remove it:
        for (index, aPeer) in enumerate(foundPeers){ //identify in the array
            if aPeer == peerID {
                foundPeers.removeAtIndex(index) //tell the ViewController class to update the tableview with the displayed peers.
                break
            }
        }
        
        delegate?.lostPeer() //call the delegate method to later reload the data
    }
    //
    
    //(10) Handling any erro that may occur if the browsing is unable to be performed. This simply displayes the error message:
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
    //
    
    //^^*3* DISPLAYING FOUND PEERS. Start at (11). Next steps: (a) go to AppDelegate Class and declare the MPCManager object, (b) Go to ViewController class to display them in the existing tableview.^^
    
    //CONTINUATION OF *5* from ViewController.Swift: (21) Allowing app to receive information
    //(21) We do automatically give the an answer to the inviter, we will ask the user if he wants to chat or not first. To do so, we temporarily store the invitation handller to a property and after the user has responded we call it in order to reply to the invitation:
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    //
    //(22) Go to viewcontroller.swift to implement the invitationWasReceivedMethod

    //(23) Connecting to a Session (back from ViewController.swft):
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:  //when connection successful
            println("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.Connecting: //for when connecting
            println("Connecting to session: \(session)")
            
        default: //for when connection did not go through
            println("Did not connect to session: \(session)")
        }
    }
//
//(24) Go to ViewController.swift to implement the connectedwithPeer method

//*6* SENDING DATA.  Start at (26)
//(26) create custom senddata method^^^^
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
            //this has two paramaters: a dictionary object that will contain the message, and the target peer.
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary) //converts the disctionary to an NSDATA object by archiving it using the NSKeyedArchiverclass
        let peersArray = NSArray(object: targetPeer)  //new array initialized with the target peer as the single object
        var error: NSError? //contains any error that may appear.
        
        if !session.sendData(dataToSend, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable, error: &error) { //if session does not go through then we display error
            println(error?.localizedDescription)
            return false
        }
        
        return true
    }
/*summary of the above:  we will use an array for storing all messages, that will be the datasource of the tableview. Each object in the array is going to be a dictionary with a string key and a string value. We create a dictionary because we need to have a pair of data for each message sent or received: the sender (author) of the message and the message itself. When our device is the one sending the message (when we’re the authors) then the self value will be set as the sender of the message in our device, while our peer display name will be sent to the other device.
*/
   /*Further detail:
this is the sendData(Data:toPeers:withMode:error:  function. it accepts the following paramaters:
    --data: The actual data that will be sent, expressed as a NSData object.
    --toPeers: An array (NSArray) with the peers that should receive the data.
    --withMode: The data sending mode. There are two modes: Reliable and Unreliable. You can use the second mode in less crucial cases, where any unreceived data won’t cause any problems at all.
    --error: A NSError object that will contain any error that may occur.
   */
//
//(27) Go to ChatViewController.swift to initialize the message array (the datasource of the tableview)
}