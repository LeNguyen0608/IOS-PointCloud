//
//  APIError.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

public enum APIErrorCode {
    public static let unknownCode = 0
    public static let badRequest = 400
    public static let unauthorizedCode = 401
    public static let invalidToken = 403
    public static let timeout = 403
    public static let notFound = 404
    public static let netWorkLost = -1005
    public static let internalServerError = 500
    public static let badGateway = 502
    public static let serviceUnavailable = 503
}

public enum APIErrorMessageCode {
    public static let invalid_token_or_device_id = "invalid_token_or_device_id"
    public static let session_timeout = "session_timeout"
}

// MARK: - APIError

public struct APIError: Error, Decodable {
    public private(set) var code = APIErrorCode.unknownCode
    public private(set) var messageCode = ""
    public private(set) var message: String = ""

    public init(error: NSError) {
        code = error.code
    }

    public init(code: Int = APIErrorCode.unknownCode,
                messageCode: String = "",
                message: String = "")
    {
        self.code = code
        self.messageCode = messageCode
        self.message = message
    }
}

class ErrorModel {
    public var errorMessage: String = ""
    public var errorMessageCode: String = ""
    public var fieldName: String = ""

    init(_ json: JSON?) {
        errorMessage = json?["errorMessage"].stringValue ?? ""
        errorMessageCode = json?["errorMessageCode"].stringValue ?? ""
        fieldName = json?["fieldName"].stringValue ?? ""
    }

    func toString() -> String {
        return String(format: "%@: %@", fieldName, errorMessageCode)
    }
}
