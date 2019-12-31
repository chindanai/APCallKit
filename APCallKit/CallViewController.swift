//
//  CallViewController.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit

class CallViewController: UIViewController {

    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var durationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "bg_call"))
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(handleCallsChangedNotification(notification:)),
                         name: APCallManager.CallsChangedNotification, object: nil)
    }
    
    deinit {
        print("CallViewController: \(#function)")
    }
    
    @objc func handleCallsChangedNotification(notification: NSNotification) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if (appdelegate.callManager.calls.count > 0) {
            let call = appdelegate.callManager.calls[0]
            if call.hasConnected && call.endDate == nil {
                durationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDurationLabel), userInfo: nil, repeats: true)
                timeLabel.text = NSLocalizedString("00:00", comment: "")
            } else {
                timeLabel.text = NSLocalizedString("Connecting...", comment: "")
            }
        }
    }
    
    @objc func updateDurationLabel() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if (appdelegate.callManager.calls.count > 0) {
            let call = appdelegate.callManager.calls[0]
            let interval = Int(call.duration)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            let hours = (interval / 3600)
            if hours > 0 {
                timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
    
    @IBAction func onEndCall(_ sender: Any) {
        DispatchQueue.main.async {
            self.durationTimer?.invalidate()
            self.durationTimer = nil
        }
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        for call in appdelegate.callManager.calls {
            appdelegate.callManager.end(call: call)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSpeaker(_ sender: Any) {
        speakerButton.isSelected = !speakerButton.isSelected
        if speakerButton.isSelected {
            OTDefaultAudioDevice.sharedInstance()?.configureAudioSession(withDesiredAudioRoute: AUDIO_DEVICE_SPEAKER)
        } else {
            OTDefaultAudioDevice.sharedInstance()?.configureAudioSession(withDesiredAudioRoute: AUDIO_DEVICE_HEADSET)
        }
    }
    
    @IBAction func onMute(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if (appdelegate.callManager.calls.count > 0) {
            let call = appdelegate.callManager.calls[0]
            call.isMuted = muteButton.isSelected
        }
    }
}
