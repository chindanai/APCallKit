//
//  StartCallConvertiable.swift
//  CallKitDemo
//
//  Created by Chindanai Peerapattanapaiboon on 30/12/2562 BE.
//  Copyright © 2562 Tokbox, Inc. All rights reserved.
//


protocol StartCallConvertible {
    var startCallHandle: String? { get }
    var video: Bool? { get }
}

extension StartCallConvertible {

    var video: Bool? {
        return nil
    }

}
