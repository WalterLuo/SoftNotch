//
//  MouseTracker.swift
//  boringNotch
//
//  Maintained by Walterluo for SoftNotch. Original attribution: docs/UPSTREAM_ATTRIBUTIONS.md.
//

import SwiftUI

extension NSScreen {
    static var screenWithMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        
        return screenWithMouse
    }
}
