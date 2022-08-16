//
//  APIRouter.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

enum HttpMethod: String {
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
}

enum ContentType: String {
    case urlFormEncoded = "application/x-www-form-urlencoded"
    case applicationJson = "application/json"
    case multipartFormData
}

protocol URLRequestConvertible {
    /// Returns a `URLRequest` or throws if an `Error` was encountered.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws:  Any error thrown while constructing the `URLRequest`.
    func asURLRequest() -> URLRequest?
}

struct APIRouter: URLRequestConvertible {
    static var baseURL: String {
        return "https://planning-poker.kardsys.com"
    }

    var path: String
    var method: HttpMethod
    var parameters: [String: Any]
    var contentType: ContentType
    var timeoutInterval: TimeInterval = 60
    
    var allHTTPHeaderFields: [String: String] {
        let headerWithToken = [
            HTTPHeaderFieldKey.contentType.rawValue: HTTPHeaderFieldValue.formUrlencoded.rawValue,
            HTTPHeaderFieldKey.appPlatform.rawValue: HTTPHeaderFieldValue.appPlatform.rawValue,
            HTTPHeaderFieldKey.appVersion.rawValue: HTTPHeaderFieldValue.appVersion,
            HTTPHeaderFieldKey.token.rawValue: HTTPHeaderFieldValue.token,
            HTTPHeaderFieldKey.deviceId.rawValue: HTTPHeaderFieldValue.deviceId
        ]

        let headerFields = [
            HTTPHeaderFieldKey.contentType.rawValue: HTTPHeaderFieldValue.applicationJson.rawValue,
            HTTPHeaderFieldKey.appPlatform.rawValue: HTTPHeaderFieldValue.appPlatform.rawValue,
            HTTPHeaderFieldKey.appVersion.rawValue: HTTPHeaderFieldValue.appVersion,
            HTTPHeaderFieldKey.deviceId.rawValue: HTTPHeaderFieldValue.deviceId
        ]

        return HTTPHeaderFieldValue.token.isEmpty ? headerFields : headerWithToken
    }

    init(path: String, method: HttpMethod = .get, parameters: [String: Any] = [:], contentType: ContentType = .urlFormEncoded) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.contentType = contentType
    }

    // MARK: - URLRequestConvertible

    func asURLRequest() -> URLRequest? {
        guard let url = URL(string: APIRouter.baseURL + path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = allHTTPHeaderFields
        var data: Data?
        switch contentType {
        case .applicationJson:
            data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        case .urlFormEncoded:
            var arrParams = [String]()
            for (key, value) in parameters {
                let param = "\(key)=\(value)"
                arrParams.append(param)
            }
            let stringParams = arrParams.joined(separator: "&")
            data = stringParams.data(using: .utf8)
        case .multipartFormData:
            break
        }
        request.httpBody = data
        request.timeoutInterval = timeoutInterval
        return request
    }
}

enum HTTPHeaderFieldKey: String {
    case contentType = "content-type"
    case appPlatform = "appplatform"
    case appVersion = "appversion"
    case token
    case deviceId = "deviceid"
}

/// The values for HTTP header fields
public enum HTTPHeaderFieldValue: String {
    case formUrlencoded = "application/x-www-form-urlencoded"
    case applicationJson = "application/json"
    case appPlatform = "1"

    static var appVersion: String {
        return AppInfo.shared.fullVersion
    }

    static var deviceId: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    static var token: String {
        return ""
    }
}

