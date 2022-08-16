//
//  APIRequest.swift
//  SceneDepthPointCloud
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

typealias ResponseBlock = (_ error: APIError?, _ response: JSON?) -> Void

final class APIRequest: NSObject {
    static let shared = APIRequest()
    
    lazy var globalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.visikard.cloudpayments.OperationQueue"
        return queue
    }()
    
    //MARK: - REQUEST METHOD
    func request(router: APIRouter,
                 _ completion: @escaping ResponseBlock)
    {
        if !Reachability.isConnectedToNetwork() {
            completion(APIError(code: APIErrorCode.netWorkLost, message: "Unable to connect the internet, please try again"), nil)
            return
        }
        switch router.method {
        case .post:
            post(router: router, completion)
        case .put:
            put(router: router, completion)
        case .get:
            get(router: router, completion)
        case .delete:
            delete(router: router, completion)
        }
    }
    
    //MARK: - GET
    private func get(router: APIRouter,
                     _ completion: @escaping ResponseBlock)
    {
        let url = APIRouter.baseURL + router.path
        guard url.isUrlLink() else {
            let error = APIError(code: APIErrorCode.notFound)
            completion(error, nil)
            return
        }
        
        guard let request = router.asURLRequest() else { return }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        print("============= Curl command: =============")
        print(request.cURL)
        print("=========================================")
        
        session.dataTask(with: request) { data, response, error in
            self.handleAPI(url: url, data: data, response: response, error: error, completion)
        }.resume()
    }
    
    //MARK: - Delete
    private func delete(router: APIRouter,
                        _ completion: @escaping ResponseBlock)
    {
        let url = APIRouter.baseURL + router.path
        guard url.isUrlLink() else {
            let error = APIError(code: APIErrorCode.notFound)
            completion(error, nil)
            return
        }
        
        guard let request = router.asURLRequest() else { return }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        print("============= Curl command: =============")
        print(request.cURL)
        print("=========================================")
        
        session.dataTask(with: request) { data, response, error in
            self.handleAPI(url: url, data: data, response: response, error: error, completion)
        }.resume()
    }
    
    //MARK: - POST
    private func post(router: APIRouter,
                      _ completion: @escaping ResponseBlock)
    {
        let url = APIRouter.baseURL + router.path
        guard url.isUrlLink() else {
            let error = APIError(code: APIErrorCode.notFound)
            completion(error, nil)
            return
        }
        
        guard let request = router.asURLRequest() else { return }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        print("============= Curl command: =============")
        print(request.cURL)
        print("=========================================")
        
        session.dataTask(with: request) { data, response, error in
            self.handleAPI(url: url, data: data, response: response, error: error, completion)
        }.resume()
    }
    
    //MARK: - PUT
    private func put(router: APIRouter,
                     _ completion: @escaping ResponseBlock)
    {
        let url = APIRouter.baseURL + router.path
        guard url.isUrlLink() else {
            let error = APIError(code: APIErrorCode.notFound)
            completion(error, nil)
            return
        }
        
        guard let request = router.asURLRequest() else { return }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        print("============= Curl command: =============")
        print(request.cURL)
        print("=========================================")
        
        session.dataTask(with: request) { data, response, error in
            self.handleAPI(url: url, data: data, response: response, error: error, completion)
        }.resume()
    }
    
    // MARK: - HandleAPI
    internal func handleAPI(url: String,
                            data: Data?, response: URLResponse?, error: Error?,
                            _ completion: @escaping ResponseBlock)
    {
        /// No Error and no success
        guard let data = data else {
            let errorHandler = handleError(nil, response: response as? HTTPURLResponse, error: error)
            if errorHandler != nil {
                completion(errorHandler, nil)
            } else {
                completion(APIError(code: APIErrorCode.unknownCode), nil)
            }
            return
        }
        /// Handle data response
        do {
            let any = try JSONSerialization.jsonObject(with: data, options: [])
            let json = JSON(any)
            print("\n URL: \(url) \n Json: \(json) \n")
            
            if let httpResponse = response as? HTTPURLResponse, error == nil, httpResponse.statusCode != 200 {
                let errorHandler = handleError(json, response: httpResponse, error: error)
                completion(errorHandler, nil)
                return
            }
            
            if let errorHandler = handleError(json, response: response as? HTTPURLResponse, error: error) {
                completion(errorHandler, nil)
            } else {
                completion(nil, json)
            }
        } catch {
            /// Exception
            let errorHandler = handleError(nil, response: response as? HTTPURLResponse, error: error)
            
            if errorHandler != nil {
                completion(errorHandler, nil)
            } else {
                completion(APIError(code: APIErrorCode.unknownCode), nil)
            }
        }
    }
}

extension APIRequest {
    func handleError(_ json: JSON?, response: HTTPURLResponse?, error: Error?) -> APIError? {
        guard let response = response else { return APIError(code: APIErrorCode.unknownCode) }

        if response.statusCode == APIErrorCode.unauthorizedCode ||
            response.statusCode == APIErrorCode.invalidToken ||
            response.statusCode == APIErrorCode.timeout ||
            response.statusCode == APIErrorCode.notFound ||
            response.statusCode == APIErrorCode.netWorkLost ||
            response.statusCode == APIErrorCode.badGateway ||
            response.statusCode == APIErrorCode.serviceUnavailable ||
            response.statusCode == APIErrorCode.badRequest
        {
            let errorMessage = json?["message"].stringValue ?? ""
//            let errorMessageCode = json?["statusCode"].stringValue ?? ""
            print("HTTPURLResponse statusCode: \(response.statusCode)")
            print("Error: \(String(describing: errorMessage))")
            return APIError(code: response.statusCode, messageCode: errorMessage)
        }
        
        if let status = json?["status"].intValue {
            if status == 0 {
                return nil
            } else {
                var errors = [ErrorModel]()
                if let errorsArray = json?["errors"].array {
                    for dic in errorsArray {
                        let value = ErrorModel(dic)
                        errors.append(value)
                    }
                }
                if errors.isEmpty {
                    return APIError(code: APIErrorCode.unknownCode,
                                    messageCode: json?["statusCode"].stringValue ?? "",
                                    message: json?["result"].stringValue ?? "")
                }
                return APIError(code: APIErrorCode.unknownCode,
                                messageCode: json?["statusCode"].stringValue ?? "",
                                message: errors.map { $0.errorMessage }.joined(separator: "\n")
                )
            }
        }
        return nil
    }
}

// MARK: - URLSessionDelegate

extension APIRequest: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let serverTrust = challenge.protectionSpace.serverTrust
        completionHandler(.useCredential, URLCredential(trust: serverTrust!))
    }
}

public extension URLRequest {
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    var cURL: String {
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
        else {
            return ""
        }
        var curlCommand = "curl"
        // Method
        curlCommand = curlCommand.appendingFormat(" -X %@ \\\n", httpMethod)
        // URL
        curlCommand = curlCommand.appendingFormat(" '%@' \\\n", url.absoluteString)
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \\\n", key, value(forHTTPHeaderField: key)!)
        }
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat(" --data '%@' \\\n", escapedHttpBody)
        }
        return curlCommand
    }

    /// Escapes all single quotes for shell from a given string.
    static func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
