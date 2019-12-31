//
//  APCall.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit
import OpenTok

class APCall: NSObject {
    
    let uuid: UUID
    let isOutgoing: Bool
    var handle: String?
    
    // MARK: State change callback blocks
    var stateDidChange: (() -> Void)?
    var startCallCompletion: ((Bool) -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    var audioChange: (() -> Void)?
    
    // MARK: Derived Properties

    var hasStartedConnecting: Bool {
        get {
            return connectingDate != nil
        }
        set {
            connectingDate = newValue ? Date() : nil
        }
    }
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }

        return Date().timeIntervalSince(connectDate)
    }
    
    // MARK: Call State Properties
    
    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    
    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    
    var isOnHold = false {
        didSet {
            publisher?.publishAudio = !isOnHold
            stateDidChange?()
        }
    }
    
    var isMuted = false {
        didSet {
            publisher?.publishAudio = !isMuted
        }
    }
    
    private var session: OTSession?
    private var publisher: OTPublisher?
    private var subscriber: OTSubscriber?
    
    init(uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.isOutgoing = isOutgoing
    }
    
    func startCall(withAudioSession audioSession: AVAudioSession, completion: ((_ success: Bool) -> Void)?) {
        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance(with: audioSession))
        if session == nil {
            session = OTSession(apiKey: Config.ApiKey, sessionId: Config.SessionId, delegate: self)
        }
        startCallCompletion = completion
        
        var error: OTError?
        hasStartedConnecting = true
        session?.connect(withToken: Config.Token, error: &error)
        if error != nil {
            print(error!)
        }
    }
    
    func startAudio() {
        if publisher == nil {
            let settings = OTPublisherSettings()
            settings.name = UIDevice.current.name
            settings.audioTrack = true
            settings.videoTrack = false
            publisher = OTPublisher.init(delegate: self, settings: settings)
        }
        
        var error: OTError?
        session?.publish(publisher!, error: &error)
        if error != nil {
            print(error!)
        }
    }
}

extension APCall: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print(#function)
        
        hasConnected = true
        startCallCompletion?(true)
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        //
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        //
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print(#function)
        subscriber = OTSubscriber.init(stream: stream, delegate: self)
        subscriber?.subscribeToVideo = false
        if let subscriber = subscriber {
            var error: OTError?
            session.subscribe(subscriber, error: &error)
            if error != nil {
                print(error!)
            }
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        //
    }
}

extension APCall: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print(#function)
    }
}

extension APCall: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print(#function)
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print(#function)
    }
}

