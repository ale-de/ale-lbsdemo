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
    var foundBot = false;
    var me:Contact = Contact();
    var botEmail = "";
    var nickName:String = "Unknown";
    var jid = "unknown"
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
    
    struct LBSbeaconMsg: Codable {
        var id: String
        var pos: String
    }
    
    func JSONparse(txt:String)->LBSbeaconMsg {
        let decoder = JSONDecoder()
        debugPrint("ALE::Decode:", txt)
        var result:LBSbeaconMsg = LBSbeaconMsg(id:"",pos:"")
        let json = txt.data(using: .utf8)!
        do {
        result = try decoder.decode(LBSbeaconMsg.self, from: json)
        }catch {debugPrint("ALE::json decode error",error)}
        return result
    }
    
    //Outlets
    @IBOutlet weak var lblGeoFenceName: UILabel!
    @IBOutlet weak var pvGeoFenceRange: UIProgressView!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var pvRSSI: UIProgressView!
    @IBOutlet weak var lblDisplayName: UILabel!
    
    //Actions
    @IBAction func btnTest_Clicked(_ sender: Any) {
        var cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: botEmail)
        if cts.count>0  {
            bot = cts[0]
            self.foundBot = true;
            debugPrint("ALE::Found contact:", bot.displayName)
            sendRainbowMsgToBot(jid:bot.jid, txt: "{\"type\":\"system\", \"data\":{\"status\":\"OK\",\"txt\":\"LBS client " + UserDefaults.standard.string(forKey: "RAINBOW-EMAIL")! + "(" + nickName + ")" + " active\"}}")
        }
        let ct = ServicesManager.sharedInstance().contactsManagerService.searchLocalContact(withEmailString: botEmail)
        if ct != nil  {
            bot = ct!
            debugPrint("ALE::Found local contact:", bot.displayName)
        }
    }
    
    func sendRainbowMsgToBot(jid: String, txt: String) {
        debugPrint("ALE::sendRainbowMsgToBot", txt,jid)
        if foundBot {
        let conversation:Conversation = ServicesManager.sharedInstance().conversationsManagerService.getConversationWithPeerJID(jid)
            if conversation != nil {
        ServicesManager.sharedInstance().conversationsManagerService.sendMessage(txt, fileAttachment: nil, to: conversation, completionHandler: nil, attachmentUploadProgressHandler: nil)
            }
        }
 
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let viewController = self.tabBarController?.viewControllers?[1] as? SecondViewController
        let _ = viewController?.view
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.settingsChanged), name: UserDefaults.didChangeNotification, object: nil)
        //loadNao()
        connectToRainbow()
        debugPrint("ALE::App has loaded")
        delegate?.logMsg(text: "App has loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector:#selector(didLogin(notification:)) , name:  NSNotification.Name(rawValue: kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLogout) , name:  NSNotification.Name(rawValue: kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didFailedToAuthenticate) , name:  NSNotification.Name(rawValue: kLoginManagerDidFailedToAuthenticate), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLogout) , name:  NSNotification.Name(rawValue: kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didRcvMsg) , name:  NSNotification.Name(rawValue: kConversationsManagerDidReceiveNewMessageForConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didLostConnection) , name:  NSNotification.Name(rawValue: kLoginManagerDidLostConnection), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didEndPopulatingMyNetwork) , name:  NSNotification.Name(rawValue: kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
    }
    deinit {
        // notifications related to the LoginManager
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLoginSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidReconnect), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidLogoutSucceeded), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kLoginManagerDidFailedToAuthenticate), object: nil)
        
        // notification related to the ContactManagerService
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kContactsManagerServiceDidEndPopulatingMyNetwork), object: nil)
        
        // notifications related to unread conversation count
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidEndLoadingConversations), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kConversationsManagerDidUpdateMessagesUnreadCount), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        }
    
    @objc func didLogin(notification: NSNotification) {
        DispatchQueue.main.async {
            let version = Tools.applicationVersion()
            self.delegate?.logMsg(text: "Rainbow login successful: app version " + version!);
            debugPrint("ALE::Rainbow login successful for " + self.me.displayName + ": app version " + version! )
        }
        DispatchQueue.main.async {self.delegate?.logMsg(text: "ALE::searching bot within 10 secs, then starting NAO")};
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            self.me = ServicesManager.sharedInstance().myUser.contact;
            let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: self.botEmail)
            if cts.count>0  {
                self.bot = cts[0];
                self.foundBot = true;
                debugPrint("ALE::Bot found:",self.bot.displayName)
                self.lblDisplayName.text = self.me.displayName
                self.delegate?.logMsg(text: "ALE::Bot found: " + (self.bot.displayName)!);
                self.sendRainbowMsgToBot(jid:self.bot.jid, txt: "{\"type\":\"system\", \"data\":{\"status\":\"OK\",\"txt\":\"LBS client " + UserDefaults.standard.string(forKey: "RAINBOW-EMAIL")! + "(" + self.nickName + ")" + " active\"}}")
                self.loadNao()
            } else {
                debugPrint("ALE::bot contact not found:"+self.botEmail)
                self.delegate?.logMsg(text: "ALE::Bot not found, trying second time");
                let cts:[Contact] = ServicesManager.sharedInstance().contactsManagerService.searchContacts(withPattern: self.botEmail)
                if cts.count>0  {
                    self.bot = cts[0];
                    self.foundBot = true;
                    debugPrint("ALE::Bot found:",self.bot.displayName)
                    self.lblDisplayName.text = self.me.displayName
                    self.delegate?.logMsg(text: "ALE::Bot found: " + (self.bot.displayName)!);
                    self.sendRainbowMsgToBot(jid:(self.bot.jid)!, txt: "{\"type\":\"system\", \"data\":{\"status\":\"OK\",\"txt\":\"LBS client " + UserDefaults.standard.string(forKey: "RAINBOW-EMAIL")! + "(" + self.nickName + ")" + " active\"}}")
                    self.loadNao()
                } else {
                self.lblDisplayName.text = "Bot not found, try manually"
                self.loadNao()
                }
            }
        })
        
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
        if apikey=="" {
            debugPrint("ALE::LBS API-KEY not configured in Settings")
            delegate?.logMsg(text: "LBS API-KEY not configured in Settings, not starting LBS")
        } else {
        nao.mLocationHandle = NAOLocationHandle(key:apikey,delegate:self as NAOLocationHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mGeofenceHandle = NAOGeofencingHandle(key:apikey,delegate:self as NAOGeofencingHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mBeaconProximityHandle = NAOBeaconProximityHandle(key:apikey,delegate:self as NAOBeaconProximityHandleDelegate,sensorsDelegate:self as NAOSensorsDelegate)
        nao.mLocationHandle.synchronizeData(self)
        }
    }
    
    func connectToRainbow() {
        let defaults:UserDefaults = UserDefaults.standard
        let email:String = defaults.string(forKey: "RAINBOW-EMAIL") ?? ""
        let pwd:String = defaults.string(forKey: "RAINBOW-PWD") ?? ""
        self.botEmail = defaults.string(forKey: "RAINBOW-BOTEMAIL") ?? ""
        if email=="" {delegate?.logMsg(text: "Rainbow loginEmail not configured in Settings")}
        if pwd=="" {delegate?.logMsg(text: "Rainbow Login password not configured in Settings")}
        if self.botEmail=="" {delegate?.logMsg(text: "Rainbow Bot name (firstname lastname) not configured in Settings")}
        
        ServicesManager.sharedInstance().notificationsManager.registerForUserNotificationsSettings { (res, err) in print("ALE::UserNotif Done")}
        if pwd != "" {
        ServicesManager.sharedInstance().loginManager.setUsername(email, andPassword: pwd);
        ServicesManager.sharedInstance().loginManager.connect();
        }
    }

    
    func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        //
        delegate?.logMsg(text: "didFailWithErrorCode:"+message)
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
            let txt:String = "{\"type\":\"geo\", \"nickName\":\"" + nickName + "\", \"data\":{\"geofence\":\"" + "" + "\",\"withEvent\":\"" + "RANGE-OUT" + "\"}}"
            //sendRainbowMsgToBot(jid:self.bot.jid, txt: txt)
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
        delegate?.logMsg(text: "didEnterGeofence " + regionName)
    }
    
    func didExitGeofence(_ regionId: Int32, andName regionName: String!) {
        //
        delegate?.logMsg(text: "didExitGeofence " + regionName)
    }
    
    func didFire(_ alert: NaoAlert!) {
        //
        //let alertInfo = alert.name.components(separatedBy: "::")
        
        delegate?.logMsg(text: "didFire for geoFence "+alert.name+" withContent "+alert.content)
        let msg = JSONparse(txt: alert.content)
        debugPrint("ALE::", msg)
        
        lblGeoFenceName.text = msg.id
        if self.foundBot {sendRainbowMsgToBot(jid:(self.bot.jid)!, txt: "{\"type\":\"geo\", \"data\":\"" + alert.content  + "\"}")}
        switch msg.pos {
        case "RANGE-IN":
            pvGeoFenceRange.setProgress(0.3, animated: true)
            
            break
        case "RANGE-OUT":
            pvGeoFenceRange.setProgress(0.0, animated: true)
            lblGeoFenceName.text = "None"
            break
        case "RANGE-NEAR":
            pvGeoFenceRange.setProgress(0.85, animated: true)
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
        NAOServicesConfig.enableOnSiteWakeUp();
    }
    
    func didSynchronizationFailure(_ errorCode: DBNAOERRORCODE, msg message: String!) {
        //
        delegate?.logMsg(text: "NAO Sync Failed");
        debugPrint("ALE::","NAO failed to start, sync failure", message );
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

