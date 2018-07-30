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

class FirstViewController: UIViewController, NAOSensorsDelegate, NAOLocationHandleDelegate, NAOSyncDelegate, NAOGeofencingHandleDelegate, NAOGeofenceHandleDelegate, NAOBeaconProximityHandleDelegate, NAOBeaconReportingHandleDelegate{

    //Variables
    var nao:Nao = Nao();
    var bot:Contact = Contact();
    var nickName:String = "";
    static let jid = "room_7002a54036f44ad38e99f32145b17103@muc.openrainbow.com"
    weak var delegate: FirstViewControllerDelegate?
    
    struct Data: Codable {
        var geofence: String
        var withEvent: String
    }
    struct MSG: Codable {
        var type: String
        var nickName: String
        var data: Data
    }
    func JSONstringify(msg: MSG) {
        do {
        let result = try JSONEncoder().encode(msg)
        debugPrint("ALE::json",result)
        }catch {debugPrint("ALE::json error",error)}
    }
    
    //Outlets
    @IBOutlet weak var lblGeoFenceName: UILabel!
    @IBOutlet weak var pvGeoFenceRange: UIProgressView!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var pvRSSI: UIProgressView!
    @IBOutlet weak var txtFindName: UITextField!
    
    //Actions
    @IBAction func btnTest_Clicked(_ sender: Any) {
        let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: "bot1")
        if cts.count>0  {bot = cts[0]}
        let conversation:Conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerJID(FirstViewController.jid)
        //debugPrint("ALE::conversation with room:", conversation)
        ServicesManager.sharedInstance().conversationsManagerService.sendMessage("Test message", fileAttachment: nil, to: conversation, completionHandler: nil, attachmentUploadProgressHandler: nil)
        //let room = ServicesManager.sharedInstance().roomsService.getRoomByJid(FirstViewController.jid)
        //ServicesManager.sharedInstance().roomsService.updateR oom(room, withTopic: "test")

    }
    
    func sendRainbowMsgToBot(txt: String) {
        debugPrint("ALE::sendRainbowMsgToBot", txt)
        let conversation:Conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerJID(FirstViewController.jid)
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
        loadNao()
        connectToRainbow()
        debugPrint("ALE::App has loaded")
        delegate?.logMsg(text: "App has loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(didLogin) , name:  NSNotification.Name(rawValue: kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didFailedToAuthenticate) , name:  NSNotification.Name(rawValue: kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLogout) , name:  NSNotification.Name(rawValue: kLoginManagerDidLogoutSucceeded), object: nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(didRcvMsg) , name:  NSNotification.Name(rawValue: kConversationsManagerDidReceiveNewMessageForConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLostConnection) , name:  NSNotification.Name(rawValue: kLoginManagerDidLostConnection), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didEndPopulatingMyNetwork) , name:  NSNotification.Name(rawValue: kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRegisterUserNotificationSettings) , name:  NSNotification.Name(rawValue: UIApplicationDidRegisterUserNotificationSettings), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRegisterForRemoteNotificationsWithDeviceToken) , name:  NSNotification.Name(rawValue: UIApplicationDidRegisterForRemoteNotificationWithDeviceToken), object: nil)
    }
    
    @objc func didRegisterUserNotificationSettings(notification: NSNotification) {
        debugPrint("ALE::didRegisterUserNotificationSettings", notification)
        UIApplication.shared.registerForRemoteNotifications();
    }
    @objc func didRegisterForRemoteNotificationsWithDeviceToken(notification: NSNotification) {
        debugPrint("ALE::didRegisterForRemoteNotificationsWithDeviceToken")
    }
    
    @objc func didEndPopulatingMyNetwork(notification: NSNotification) {
        debugPrint("ALE::didEndPopulatingMyNetwork")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: "bot1")
            if cts.count>0  {self.bot = cts[0]; debugPrint("ALE::Bot found:",self.bot)}
            self.sendRainbowMsgToBot(txt: "{\"type\":\"system\", \"data\":{\"status\":\"OK\",\"txt\":\"LBS client " + UserDefaults.standard.string(forKey: "RAINBOW-EMAIL")! + "(" + self.nickName + ")" + " active\"}}")
        })
    }
    
    @objc func didLogin(notification: NSNotification) {
        DispatchQueue.main.async {
            let version = Tools.applicationVersion()
            self.delegate?.logMsg(text: "Rainbow login successful: version " + version!);
        }
        nickName = ServicesManager.sharedInstance().myUser.contact.fullName;
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
        debugPrint("ALE::Message:",notification)
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
        let apikey:String = defaults.string(forKey: "LBS-API-KEY") ?? ""
        if apikey=="" {delegate?.logMsg(text: "LBS API-KEY not configured in Settings")}
        nao.mLocationHandle = NAOLocationHandle(key:apikey,delegate:self as NAOLocationHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mGeofenceHandle = NAOGeofencingHandle(key:apikey,delegate:self as NAOGeofencingHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mBeaconProximityHandle = NAOBeaconProximityHandle(key:apikey,delegate:self as NAOBeaconProximityHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mLocationHandle.synchronizeData(self)
    }
    
    func connectToRainbow() {
        let defaults:UserDefaults = UserDefaults.standard
        let email:String = defaults.string(forKey: "RAINBOW-EMAIL") ?? ""
        let pwd:String = defaults.string(forKey: "RAINBOW-PWD") ?? ""
        if email=="" {delegate?.logMsg(text: "Rainbow loginEmail not configured in Settings")}
        if pwd=="" {delegate?.logMsg(text: "Rainbow Login password not configured in Settings")}
        ServicesManager.sharedInstance().notificationsManager.registerForUserNotificationsSettings { (res, err) in print("Done")
            
        }
        
        ServicesManager.sharedInstance().loginManager.setUsername(email, andPassword: pwd);
        ServicesManager.sharedInstance().loginManager.connect();

    }
    
    func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        //
        delegate?.logMsg(text: "didFailWithErrorCode")
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
            sendRainbowMsgToBot(txt: "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + "" + "\",\"withEvent\":\"" + "RANGE-OUT" + "\"}}")
            lblGeoFenceName.text = "None"
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
        delegate?.logMsg(text: "didEnterGeofence")
    }
    
    func didExitGeofence(_ regionId: Int32, andName regionName: String!) {
        //
        delegate?.logMsg(text: "didExitGeofence")
    }
    
    func didFire(_ alert: NaoAlert!) {
        //
        let alertInfo = alert.name.components(separatedBy: "::")
        delegate?.logMsg(text: "didFire for geoFence "+alertInfo[0]+" withEvent "+alertInfo[1])
        lblGeoFenceName.text = alertInfo[0]
        switch alertInfo[1] {
        case "RANGE-IN":
            pvGeoFenceRange.setProgress(0.3, animated: true)
            sendRainbowMsgToBot(txt: "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + alertInfo[0] + "\",\"withEvent\":\"" + alertInfo[1] + "\"}}")
            break
        case "RANGE-OUT":
            pvGeoFenceRange.setProgress(0.0, animated: true)
            lblGeoFenceName.text = "None"
            sendRainbowMsgToBot(txt: "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + alertInfo[0] + "\",\"withEvent\":\"" + alertInfo[1] + "\"}}")
            break
        case "RANGE-NEAR":
            pvGeoFenceRange.setProgress(0.85, animated: true)
            sendRainbowMsgToBot(txt: "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + alertInfo[0] + "\",\"withEvent\":\"" + alertInfo[1] + "\"}}")
            break
        case "RANGE-FAR":
            pvGeoFenceRange.setProgress(0.5, animated: true)
            sendRainbowMsgToBot(txt: "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + alertInfo[0] + "\",\"withEvent\":\"" + alertInfo[1] + "\"}}")
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
        NAOServicesConfig.enableOnSiteWakeUp();
    }
    
    func didSynchronizationFailure(_ errorCode: DBNAOERRORCODE, msg message: String!) {
        //
        debugPrint("ALE::","NAO failed to start" );
    }
    
    
    func didLocationChange(_ location: CLLocation!) {
        //
        //delegate?.logMsg(text: "Location changed")
        //debugPrint(location)
    }
    
    func didLocationStatusChanged(_ status: DBTNAOFIXSTATUS) {
        //
        delegate?.logMsg(text: "Location status changed")
    }
    
    func requiresWifiOn() {
        //
        delegate?.logMsg(text: "requiresWifiOn")
    }
    
    func requiresBLEOn() {
        //
        delegate?.logMsg(text: "requiresBLEOn")
    }
    
    func requiresLocationOn() {
        //
        delegate?.logMsg(text: "requiresLocationOn")
    }
    
    func requiresCompassCalibration() {
        //
        delegate?.logMsg(text: "requiresCompassCalibration")
    }
    
    func pushAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        //alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}

