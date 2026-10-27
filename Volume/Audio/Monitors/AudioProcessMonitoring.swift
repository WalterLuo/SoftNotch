//
//  AudioProcessMonitoring.swift
//  SoftNotch
//
//  Created by Shariq Charolia on 2026-08-21

@MainActor
protocol AudioProcessMonitoring: AnyObject {
    var activeApps: [AudioApp] { get }
    var onAppsChanged: (([AudioApp]) -> Void)? { get set }

    func start()
    func stop()
}