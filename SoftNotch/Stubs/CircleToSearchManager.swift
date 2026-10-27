//
//  CircleToSearchManager.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-08-30

#if !SOFTNOTCH_FULL_BUILD
import Foundation

final class CircleToSearchManager {
    static let shared = CircleToSearchManager()
    private init() {}

    func endResultsPresentation() {}
}

extension Notification.Name {
    static let softnotchOpenCircleToSearch = Notification.Name("softnotchOpenCircleToSearch")
}
#endif