//
//  MicrophoneUsageManagerTests.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-09-15

import XCTest
@testable import SoftNotch

final class MicrophoneUsageManagerTests: XCTestCase {
    func testSoftNotchProcessTapDoesNotCountAsMicrophoneUse() {
        XCTAssertFalse(MicrophoneUsageFilter.shouldCount(
            processID: 200,
            bundleID: "com.google.Chrome",
            inputDeviceNames: ["SoftNotch-com.google.Chrome"],
            ownProcessID: 100,
            ownBundleID: "com.walterluo.softnotch"
        ))
    }

    func testBrowserUsingPhysicalMicrophoneStillCounts() {
        XCTAssertTrue(MicrophoneUsageFilter.shouldCount(
            processID: 200,
            bundleID: "com.google.Chrome",
            inputDeviceNames: ["SoftNotch-com.google.Chrome", "MacBook Pro Microphone"],
            ownProcessID: 100,
            ownBundleID: "com.walterluo.softnotch"
        ))
    }

    func testSoftNotchProcessIsIgnoredEvenWhenCoreAudioOmitsBundleID() {
        XCTAssertFalse(MicrophoneUsageFilter.shouldCount(
            processID: 100,
            bundleID: nil,
            inputDeviceNames: ["MacBook Pro Microphone"],
            ownProcessID: 100,
            ownBundleID: "com.walterluo.softnotch"
        ))
    }

    func testProcessWithoutAnInputDeviceDoesNotCount() {
        XCTAssertFalse(MicrophoneUsageFilter.shouldCount(
            processID: 200,
            bundleID: "com.google.Chrome",
            inputDeviceNames: [],
            ownProcessID: 100,
            ownBundleID: "com.walterluo.softnotch"
        ))
    }
}