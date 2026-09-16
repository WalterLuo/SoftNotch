//
//  NotchSpaceManager.swift
//  boringNotch
//
//  Maintained by Walterluo for SoftNotch. Original attribution: docs/UPSTREAM_ATTRIBUTIONS.md.
//

import Foundation

class NotchSpaceManager {
    static let shared = NotchSpaceManager()
    let notchSpace: CGSSpace
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private init() {
        notchSpace = CGSSpace(level: 2147483647) // Max level
    }
}
