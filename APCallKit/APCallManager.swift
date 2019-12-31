
//
//  APCallManager.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit
import CallKit

class APCallManager: NSObject {

    let callController = CXCallController()
    private(set) var calls = [APCall]()
    
    func startCall(handle: String, video: Bool = false) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)

        startCallAction.isVideo = video

        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction, action: "startCall")
    }
    
    func end(call: APCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction, action: "endCall")
    }
    
    func addCall(_ call: APCall) {
        calls.append(call)
    }
    
    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction \(action) successfully")
            }
        }
    }
}
