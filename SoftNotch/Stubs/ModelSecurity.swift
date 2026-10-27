//
//  ModelSecurity.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-08-30

#if !SOFTNOTCH_FULL_BUILD
import Foundation
import CryptoKit

enum ModelSecurity {
    static let encryptionKey = SymmetricKey(data: Data(count: 32))
}
#endif