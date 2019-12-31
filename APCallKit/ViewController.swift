//
//  ViewController.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func callButtonPressed(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        appdelegate.callManager.startCall(handle: "Amanda")
    }
    
    @IBAction func endCall(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        for call in appdelegate.callManager.calls {
            appdelegate.callManager.end(call: call)
        }
    }
    
    @IBAction func simulateIncomingCall(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appdelegate.displayIncomingCall(uuid: UUID(), handle: "Cerny")
    }
    
    @IBAction func simulateIncomingCallAfterSeconds(_ sender: UIButton) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            appdelegate.displayIncomingCall(uuid: UUID(), handle: "Cerny", hasVideo: false) { _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
    }
}

