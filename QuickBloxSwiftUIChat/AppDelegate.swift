//
//  AppDelegate.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 06.07.2021.
//

import UIKit
import UserNotifications
import Quickblox
 
struct CredentialsConstant {
    static let applicationID:UInt = 92137
    static let authKey = "bNR4tHJh6ejLP5M"
    static let authSecret = "OR7Lc9SpNRBuFAa"
    static let accountKey = "hiaW8XawsCJrHarjYmpz"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.applicationIconBadgeNumber = 0
        window?.backgroundColor = .white;
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        QBSettings.disableFileLogging()
        QBSettings.autoReconnectEnabled = true
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Logging out from chat.
//        ChatManager.instance.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
//        ChatManager.instance.connect()
    }
    
    //MARK: - UNUserNotification
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        
        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
        }, errorBlock: { response in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("[AppDelegate] Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

