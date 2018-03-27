//
//  FirstViewController.swift
//  ale-lbs
//
//  Created by Dirk Evrard on 19/03/18.
//  Copyright © 2018 Dirk Evrard. All rights reserved.
//

import UIKit

protocol FirstViewControllerDelegate: class {
    func logMsg(text:String?)
}

class FirstViewController: UIViewController, NAOSensorsDelegate, NAOLocationHandleDelegate, NAOSyncDelegate, NAOGeofencingHandleDelegate, NAOGeofenceHandleDelegate, NAOBeaconProximityHandleDelegate{

    //Variables
    var nao:Nao = Nao();
    var bot:Contact = Contact();
    weak var delegate: FirstViewControllerDelegate?
    
    //Outlets
    @IBOutlet weak var lblGeoFenceName: UILabel!
    @IBOutlet weak var pvGeoFenceRange: UIProgressView!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var pvRSSI: UIProgressView!
    @IBOutlet weak var txtFindName: UITextField!
    
    //Actions
    @IBAction func btnTest_Clicked(_ sender: Any) {
        let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: "bot1")
        debugPrint(cts[0])
        let conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerJID(cts[0].jid)
        ServicesManager.sharedInstance().conversationsManagerService.sendMessage("Test message", fileAttachment: nil, to: conversation, completionHandler: nil, attachmentUploadProgressHandler: nil)
    }
    
    func sendRainbowMsgToBot(txt: String) {
        let conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerJID(bot.jid)
        ServicesManager.sharedInstance().conversationsManagerService.sendMessage(txt, fileAttachment: nil, to: conversation, completionHandler: nil, attachmentUploadProgressHandler: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFindName.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let viewController = self.tabBarController?.viewControllers?[1] as? SecondViewController
        let _ = viewController?.view
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
        debugPrint("ALE :: home page loaded")
        delegate?.logMsg(text: "Home page loaded")
        loadNao()
        connectToRainbow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(didLogin) , name:  NSNotification.Name(rawValue: kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didFailedToAuthenticate) , name:  NSNotification.Name(rawValue: kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLogout) , name:  NSNotification.Name(rawValue: kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRcvMsg) , name:  NSNotification.Name(rawValue: kConversationsManagerDidReceiveNewMessageForConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLostConnection) , name:  NSNotification.Name(rawValue: kLoginManagerDidLostConnection), object: nil)

    }
    
    @objc func didLogin(notification: NSNotification) {
        DispatchQueue.main.async {self.delegate?.logMsg(text: "Rainbow login successful")}
        let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: "bot1")
        bot = cts[0]
        debugPrint(bot)

    }
    @objc func didFailedToAuthenticate(notification: NSNotification) {
        DispatchQueue.main.async {self.delegate?.logMsg(text: "Rainbow auth failed")}
    }
    @objc func didLogout(notification: NSNotification) {
        DispatchQueue.main.async {self.delegate?.logMsg(text: "Rainbow logout successful")}
    }
    @objc func didLostConnection(notification: NSNotification) {
        DispatchQueue.main.async {self.delegate?.logMsg(text: "Rainbow lost connection")}
    }
    @objc func didRcvMsg(notification: NSNotification) {
        debugPrint("DEBUG::Message:",notification)
        DispatchQueue.main.async {self.delegate?.logMsg(text: "Rainbow Received msg")}
    }

    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func settingsChanged(){
        //let defaults:UserDefaults = UserDefaults.standard
        //let api:String = defaults.string(forKey: "RAINBOW-EMAIL")!
        //debugPrint("api key:", api)
    }
    
    func loadNao() {
        let defaults:UserDefaults = UserDefaults.standard
        let apikey:String = defaults.string(forKey: "LBS-API-KEY")!
        nao.mLocationHandle = NAOLocationHandle(key:apikey,delegate:self as NAOLocationHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mGeofenceHandle = NAOGeofencingHandle(key:apikey,delegate:self as NAOGeofencingHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mBeaconProximityHandle = NAOBeaconProximityHandle(key:apikey,delegate:self as NAOBeaconProximityHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mLocationHandle.synchronizeData(self)
    }
    
    func connectToRainbow() {
        let defaults:UserDefaults = UserDefaults.standard
        let email:String = defaults.string(forKey: "RAINBOW-EMAIL")!
        let pwd:String = defaults.string(forKey: "RAINBOW-PWD")!
        ServicesManager.sharedInstance().loginManager.setUsername(email, andPassword: pwd);
        ServicesManager.sharedInstance().loginManager.connect();

    }
    
    func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        //
    }
    
    func didRangeBeacon(_ beaconPublicID: String!, withRssi rssi: Int32) {
        //
        lblRSSI.text = String(1.0-Float(rssi+40)/(-50))
        pvRSSI.setProgress(1.0-Float(rssi+40)/(-50), animated: true)
        //delegate?.logMsg(text: "RSSI:"+String(rssi))
    }
    
    func didProximityChange(_ proximity: DBTBEACONSTATE, forBeacon beaconPublicID: String!) {
        //
        switch proximity {
        case DBTBEACONSTATE.NO_CHANGE:
            delegate?.logMsg(text: "BEACONSTATE No change")
        case DBTBEACONSTATE.FIRST_UNSEEN:
            delegate?.logMsg(text: "BEACONSTATE Out of range")
            pvGeoFenceRange.setProgress(0.0, animated: true)
        case DBTBEACONSTATE.FIRST_UNKNOWN:
            delegate?.logMsg(text: "BEACONSTATE Transitory")
        case DBTBEACONSTATE.FIRST_FAR:
            delegate?.logMsg(text: "BEACONSTATE Below proximity")
            //pvGeoFenceRange.setProgress(0.5, animated: true)
        case DBTBEACONSTATE.FIRST_NEAR:
            delegate?.logMsg(text: "BEACONSTATE Above proximity")
            pvGeoFenceRange.setProgress(0.85, animated: true)
        default:
            delegate?.logMsg(text: "BEACONSTATE Unknown")
        }
    }
    
    func didEnterGeofence(_ regionId: Int32, andName regionName: String!) {
        //
    }
    
    func didExitGeofence(_ regionId: Int32, andName regionName: String!) {
        //
    }
    
    func didFire(_ alert: NaoAlert!) {
        //
        let alertInfo = alert.name.components(separatedBy: "::")
        delegate?.logMsg(text: "didFire for geoFence "+alertInfo[0]+" withEvent "+alertInfo[1])
        lblGeoFenceName.text = alertInfo[0]
        switch alertInfo[1] {
        case "RANGE-IN":
            pvGeoFenceRange.setProgress(0.3, animated: true)
            break
        case "RANGE-OUT":
            pvGeoFenceRange.setProgress(0.0, animated: true)
            lblGeoFenceName.text = "None"
            sendRainbowMsgToBot(txt: "{geofence:'" + alertInfo[0] + "',withEvent:'" + alertInfo[1] + "'}")
            break
        case "RANGE-NEAR":
            pvGeoFenceRange.setProgress(0.85, animated: true)
            sendRainbowMsgToBot(txt: "{geofence:'" + alertInfo[0] + "',withEvent:'" + alertInfo[1] + "'}")
            break
        case "RANGE-FAR":
            pvGeoFenceRange.setProgress(0.5, animated: true)
            break
        default:
            break
        }
    }
    
    func didSynchronizationSuccess() {
        //
        delegate?.logMsg(text: "NAO Sync OK")
        nao.mLocationHandle.start();
        nao.mGeofenceHandle.start();
        nao.mBeaconProximityHandle.start();
        delegate?.logMsg(text: "NAO ready, version:" + NAOServicesConfig.getSoftwareVersion())
    }
    
    func didSynchronizationFailure(_ errorCode: DBNAOERRORCODE, msg message: String!) {
        //
        debugPrint("NAO failed to start" );
    }
    
    
    func didLocationChange(_ location: CLLocation!) {
        //
        //delegate?.logMsg(text: "Location changed")
    }
    
    func didLocationStatusChanged(_ status: DBTNAOFIXSTATUS) {
        //
        delegate?.logMsg(text: "Location status changed")
    }
    
    func requiresWifiOn() {
        //
    }
    
    func requiresBLEOn() {
        //
    }
    
    func requiresLocationOn() {
        //
    }
    
    func requiresCompassCalibration() {
        //
    }
}

