//
//  NSUserActivity+StartCallConvertible.swift
//  CallKitDemo
//
//  Created by Chindanai Peerapattanapaiboon on 30/12/2562 BE.
//  Copyright © 2562 Tokbox, Inc. All rights reserved.
//

import Foundation
import Intents

extension NSUserActivity: StartCallConvertible {

    var startCallHandle: String? {
        guard
          let interaction = interaction,
          let startCallIntent = interaction.intent as? SupportedStartCallIntent,
          let contact = startCallIntent.contacts?.first
        else {
            return nil
        }

        return contact.personHandle?.value
    }

    var video: Bool? {
        guard
          let interaction = interaction,
          let startCallIntent = interaction.intent as? SupportedStartCallIntent
        else {
            return nil
        }

        return startCallIntent is INStartVideoCallIntent
    }
    
}

protocol SupportedStartCallIntent {
    var contacts: [INPerson]? { get }
}

extension INStartAudioCallIntent: SupportedStartCallIntent {}
extension INStartVideoCallIntent: SupportedStartCallIntent {}
