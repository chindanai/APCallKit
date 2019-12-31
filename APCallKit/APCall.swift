//
//  APCall.swift
//  APCallKit
//
//  Created by Chindanai Peerapattanapaiboon on 31/12/2562 BE.
//  Copyright © 2562 Chindanai Peerapattanapaiboon. All rights reserved.
//

import UIKit

class APCall: NSObject {
    
    let uuid: UUID
    let isOutgoing: Bool
    var handle: String?
    
    init(uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.isOutgoing = isOutgoing
    }
}
