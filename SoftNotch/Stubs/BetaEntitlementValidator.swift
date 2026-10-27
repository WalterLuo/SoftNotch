//
//  BetaEntitlementValidator.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-08-30

#if !SOFTNOTCH_FULL_BUILD
import Foundation

class BetaEntitlementValidator: NSObject {
    required override init() {}
    func validateBetaEntitlement() -> Bool { true }
}

enum BetaEntitlementRuntime {
    static var isBetaBuild: Bool { false }
    static func makeValidator() -> BetaEntitlementValidator { BetaEntitlementValidator() }
}
#endif