//
//  Configuration.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

struct AppInfo {
    static let shared = AppInfo()
    var version: String {
        return readFromInfoPlist(withKey: "CFBundleShortVersionString") ?? "(unknown app version)"
    }
    var build: String {
        return readFromInfoPlist(withKey: "CFBundleVersion") ?? "(unknown build number)"
    }
    var fullVersion: String {
        return "\(version).\(build)"
    }
    // lets hold a reference to the Info.plist of the app as Dictionary
    private let infoPlistDictionary = Bundle.main.infoDictionary
    /// Retrieves and returns associated values (of Type String) from info.Plist of the app.
    private func readFromInfoPlist(withKey key: String) -> String? {
        return infoPlistDictionary?[key] as? String
    }
}
