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
    
    var invitationHandler: ((Bool, MCSession!)->Void)!
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



}