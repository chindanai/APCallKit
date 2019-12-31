//
//  ProviderDelegate.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation

class ProviderDelegate: NSObject {
    private var provider: CXProvider
    let callManager: APCallManager
    
    init(callManager: APCallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)

        super.init()

        provider.setDelegate(self, queue: nil)
    }
    
    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("APCallKit", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        providerConfiguration.supportsVideo = false

        providerConfiguration.maximumCallsPerCallGroup = 1

        providerConfiguration.supportedHandleTypes = [.phoneNumber]

        providerConfiguration.iconTemplateImageData = #imageLiteral(resourceName: "logo").pngData()

        providerConfiguration.ringtoneSound = "Ringtone.caf"
        
        return providerConfiguration
    }
    
    public func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo

        // pre-heat the AVAudioSession
        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = APCall(uuid: uuid)
                call.handle = handle
                self.callManager.addCall(call)
            }
            
            completion?(error as NSError?)
        }
    }
    
    private func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try session.setActive(true)
            try session.setMode(AVAudioSession.Mode.voiceChat)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
        } catch {
            print(error)
        }
    }
}

extension ProviderDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = APCall(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value
        self.callManager.addCall(call)
        configureAudioSession()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        //
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        //
    }
}
