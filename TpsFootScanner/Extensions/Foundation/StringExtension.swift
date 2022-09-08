//
//  StringExtension.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation

extension String {
    func isUrlLink() -> Bool {
        guard self.starts(with: "https") || self.starts(with: "http") else { return false }
        let urlPattern = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let result = self.matches(pattern: urlPattern)
        return result
    }

    private func matches(pattern: String) -> Bool {
        let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive])
        return regex?.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf16.count)) != nil
    }
    var isValidPhoneNumber: Bool {
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
        if let match = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count)).first?.phoneNumber {
            return match == self
        } else {
            return false
        }
    }
    // MARK: - CheckFormatEmail
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    // MARK: - CheckFormatPassword
    var isCorrectFormatPassword: Bool {
        let formatPasswordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])(?=.*[0-9])[a-zA-Z0-9\\d@$!%*?&]{8,}$"
        let formatPredicate = NSPredicate(format: "SELF MATCHES %@", formatPasswordRegEx)
        return formatPredicate.evaluate(with: self)
    }
    // MARK: - CheckMatch
    func isFieldMatch(with compareValue: String) -> Bool {
        let standValue = self
        if standValue == compareValue {
            return true
        }
        return false
    }
}
