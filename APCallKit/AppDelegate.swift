//
//  AppDelegate.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = APCallManager()
    var providerDelegate: ProviderDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let handle = userActivity.startCallHandle else {
            print("Could not determine start call handle from user activity: \(userActivity)")
            return false
        }

        callManager.startCall(handle: handle, video: false)
        return true
    }
    
    // Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
       providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token.map { String(format: "%02.2hhx", $0) }.joined())
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print(payload.dictionaryPayload)
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
            let handle = payload.dictionaryPayload["handle"] as? String,
            let uuid = UUID(uuidString: uuidString) {
            
            // display incoming call UI when receiving incoming voip notification
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false) { _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
}
