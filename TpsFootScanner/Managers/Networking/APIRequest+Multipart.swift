//
//  APIRequest+Multipart.swift
//  TpsFootScanner
//
//  Created by Nguyen Le on 8/16/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

typealias UploadProgressBlock = (_ progress: Double) -> Void

// MARK: - Upload Multipart

extension APIRequest {
    func requestUploadMultipart(router: APIRouter,
                                multipartDatas: [MultipartData] = [],
                                uploadProgressBlock: @escaping UploadProgressBlock = { _ in },
                                _ completion: @escaping ResponseBlock)
    {
        if !Reachability.isConnectedToNetwork() {
            completion(APIError(code: APIErrorCode.netWorkLost, message: "Unable to connect the internet, please try again"), nil)
            return
        }
        let url = APIRouter.baseURL + router.path
        guard url.isUrlLink() else {
            let error = APIError(code: APIErrorCode.notFound)
            completion(error, nil)
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: URLSessionDataProxyDelegate(uploadProgressBlock: uploadProgressBlock), delegateQueue: globalQueue)
        
        // Set the URLRequest to POST and to the specified URL
        guard var request = router.asURLRequest() else { return }
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        let boundary = "Boundary-" + UUID().uuidString
        let data = createMultipartParamsBodyData(multipartDatas: multipartDatas, boundary: boundary)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        print("curl command: " + (request.cURL.count > 5000 ? "" : request.cURL))
        
        // Send a POST request to the URL, with the data we created earlier
        let uploadTask = session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                self.handleAPI(url: url, data: data, response: response, error: error, completion)
            }
        })
        uploadTask.resume()
    }
    
    private func createMultipartParamsBodyData(multipartDatas: [MultipartData], boundary: String) -> Data {
        var data = Data()
        
        let startBound = "--\(boundary)" + "\r\n"
        let centerBound = "\r\n" + "--\(boundary)" + "\r\n"
        let endBound = "\r\n" + "--\(boundary)--" + "\r\n"
        
        let contentDisposition = "Content-Disposition: form-data; name=\"%@\"" + "\r\n" + "\r\n"
        let fileContentDisposition = "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"" + "\r\n"
        
        let contentType = "Content-Type: %@" + "\r\n" + "\r\n"
        
        
        for (index, multipartData) in multipartDatas.enumerated() {
            if index == 0 {
                data.append(startBound.utf8Data)
            } else {
                data.append(centerBound.utf8Data)
            }
            
            if let multipartData = multipartData as? MultipartDataString {
                data.append(String(format: contentDisposition, multipartData.key).utf8Data)
                data.append(multipartData.payload.utf8Data)
            } else if let multipartData = multipartData as? MultipartDataFile {
                data.append(String(format: fileContentDisposition,
                                   multipartData.key,
                                   multipartData.fileName
                                  ).utf8Data)
                data.append(String(format: contentType,
                                   multipartData.mineType).utf8Data)
                data.append(multipartData.payload)
            } else {
                debugPrint("Request with invalid payload")
                continue
            }
        }
        data.append(endBound.utf8Data)
        return data
    }
    
    func sendAPI(parameters: [[String: Any]], _ completion: @escaping (String, Double, Double) -> ()) {
        var semaphore = DispatchSemaphore (value: 0)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var error: Error? = nil
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as? String ?? "")"
                }
                let paramType = param["type"] as? String ?? ""
                if paramType == "text" {
                    let paramValue = param["value"] as? String ?? ""
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    if let paramSrc = param["src"] as? String, let fileData = try? NSData(contentsOfFile:paramSrc, options:[]) as Data, let fileContent = String(data: fileData as Data, encoding: .ascii) {
                        body += "; filename=\"\(paramSrc)\"\r\n"
                        + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                    }
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .ascii)
        
        var request = URLRequest(url: URL(string: "http://113.161.39.34:8088/api/upload-file")!,timeoutInterval: Double.infinity)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let any = try JSONSerialization.jsonObject(with: data, options: [])
                let json = JSON(any)
                
                if let imageData = json["data"]["image"].rawValue as? String {
                    completion(imageData,  json["data"]["width"].doubleValue, json["data"]["height"].doubleValue)
                } else {
                    completion("", 0.0 , 0.0)
                }
                
            } catch {
                
            }

            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
}

// MARK: - MultipartData

class MultipartData {
    var key: String = ""
    
    fileprivate init(key: String) {
        self.key = key
    }
}

final class MultipartDataFile: MultipartData {
    var fileName: String
    var payload: Data
    var mineType: String
    
    
    init(key: String,
         fileName: String,
         payload: Data,
         mineType: String
    )
    {
        self.fileName = fileName
        self.payload = payload
        self.mineType = mineType
        super.init(key: key)
    }
}

final class MultipartDataString: MultipartData {
    var payload: String
    
    init(key: String,
         payload: String)
    {
        self.payload = payload
        super.init(key: key)
    }
}

// MARK: - Private Extensions

private extension String {
    var utf8Data: Data {
        return data(using: .utf8) ?? Data()
    }
}

// MARK: - URLSessionDataProxyDelegate

final class URLSessionDataProxyDelegate: NSObject, URLSessionDataDelegate, URLSessionDelegate {
    var uploadProgressBlock: UploadProgressBlock?
    
    init(uploadProgressBlock: UploadProgressBlock?) {
        super.init()
        self.uploadProgressBlock = uploadProgressBlock
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Complete upload with error " + error.debugDescription)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceive response")
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("totalBytesExpectedToSend:\(totalBytesExpectedToSend) - totalBytesSent:\(totalBytesSent) - bytesSent:\(bytesSent)")
        guard let uploadProgressBlock = uploadProgressBlock else { return }
        
        uploadProgressBlock(totalBytesSent == 0 ? 0 : Double(bytesSent / totalBytesSent))
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let serverTrust = challenge.protectionSpace.serverTrust
        completionHandler(.useCredential, URLCredential(trust: serverTrust!))
    }
}
