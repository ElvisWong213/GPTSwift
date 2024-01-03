//
//  KeychainService.swift
//  GPTSwift
//
//  Created by Elvis on 11/12/2023.
//

import Foundation
import KeychainSwift

final class KeychainService {
    static private let keychain = KeychainSwift()
    static private let keyName = "gptApiKey"
    
    static func setKey(key:  String) {
        DispatchQueue.global().async {
            keychain.set(key, forKey: keyName)
        }
    }
    
    static func getKey() -> String {
        return keychain.get(keyName) ?? ""
    }
    
    static func deleteKey() -> Bool {
        return keychain.delete(keyName)
    }
}
