//
//  EasyNetRequest.swift
//
//  Created by Osmely Fernandez on 12/6/19.
//  Basado en https://github.com/fmo91/Conn
//  Copyright © 2019 Osmely Fernandez. All rights reserved.
//

import Foundation


//==========================================
// MARK: - EasyNetError -
//==========================================

public enum EasyNetError: Error {
    case invalidURL
    case noData
    case noJson
}


//==========================================
// MARK: - EasyNetHTTPMethod -
//==========================================

public enum EasyNetHTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}


//==========================================
// MARK: - EasyNetRequestData -
//==========================================

public struct EasyNetRequestData {
    public let path: String
    public let method: EasyNetHTTPMethod
    public let params: [String: Any?]?
    public let headers: [String: String]?
    
    
    public init (
        path: String,
        method: EasyNetHTTPMethod,
        params: [String: Any?]? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        
        var h = headers ?? [:]
        h["Content-Type"] = h["Content-Type"] ?? "application/json"
        
        self.headers = h
    }
}


//==========================================
// MARK: - EasyNetResponseValidator -
//==========================================
public protocol EasyNetResponseValidator {
    func validate(json: Any) throws
}


//==========================================
// MARK: - EasyNetRequest -
//==========================================

public protocol EasyNetRequest {
    associatedtype EasyNetResponseType: Codable
    var data: EasyNetRequestData { get }
    var validators: [EasyNetResponseValidator]? {get}
    func log(data:String)
}

public extension EasyNetRequest {
    
    func execute (
        dispatcher: EasyNetDispatcher = URLSessionEasyNetDispatcher.instance,
        onResult: @escaping (Result<EasyNetResponseType, Error>) -> Void
    ) {
    
        var logStr = ""
        logStr = logStr + "===================================================\n"
        logStr = logStr + "Request sent to \(self.data.path)\n"
        logStr = logStr + "Method: \(self.data.method.rawValue)\n"
        logStr = logStr + "Headers: \(self.data.headers ?? [:])\n"
        logStr = logStr + "Parameters: \(getPrintableJSON(self.data.params ?? [:]))\n"
        logStr = logStr + "---------------------------------------------------"
        log(data: logStr);logStr = ""
        
        
        dispatcher.dispatch(request: self.data) { (result) in
            
            do {
                let result_data = try result.get()
                
                //JSON validation
                if let validators = self.validators  {
                    if let responseJSON = try? JSONSerialization.jsonObject(with: result_data, options: []) {
                        for validator in validators {
                            do {
                                try validator.validate(json: responseJSON)
                            } catch let error {
                                
                                
                                logStr = logStr + "Validator Failed --> \(error)\n"
                                logStr = logStr + "===================================================\n"
                                self.log(data: logStr);logStr = ""
                                
                                DispatchQueue.main.async {
                                    onResult(.failure(error))
                                }
                                return
                            }
                        }
                    } else {
                        
                        logStr = logStr + "Error:\n"
                        logStr = logStr + "\(EasyNetError.noJson):\n"
                        logStr = logStr + "===================================================\n"
                        self.log(data: logStr);logStr = ""
                        
                        DispatchQueue.main.async {
                            onResult(.failure(EasyNetError.noJson))
                        }
                        return
                    }
                }
                
                //Decode to object
                let jsonDecoder = JSONDecoder()
                let result = try jsonDecoder.decode(EasyNetResponseType.self, from: result_data)
                
                logStr = logStr + "---------------------------------------------------\n"
                logStr = logStr + "Request sent to \(self.data.path)\n"
                logStr = logStr + "Response:\n"
                logStr = logStr + "\(self.prettyPrintedJSONString(result_data) ?? "{}")\n"
                logStr = logStr + "===================================================\n"
                self.log(data: logStr);logStr = ""
                
                DispatchQueue.main.async {
                    onResult(.success(result))
                }
                
            }catch let error {
                
                logStr = logStr + "---------------------------------------------------\n"
                logStr = logStr + "Request sent to \(self.data.path)\n"
                logStr = logStr + "Error:\n"
                logStr = logStr + "\(error):\n"
                logStr = logStr + "===================================================\n"
                self.log(data: logStr);logStr = ""
                
                DispatchQueue.main.async {
                    onResult(.failure(error))
                }
            }
        }
    }
    
    func log(data:String){print(data)}
    
    private func JSONStringify(_ value: AnyObject, prettyPrinted:Bool = false) -> String{
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                print("error")
            }
        }
        return ""
    }

    private func getPrintableJSON(_ json: AnyObject) -> NSString {
        return JSONStringify(json, prettyPrinted: true) as NSString
    }

    private func getPrintableJSON(_ json: Any) -> NSString {
        return getPrintableJSON(json as AnyObject)
    }

    private func prettyPrintedJSONString(_ data : Data) -> NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }

}


//==========================================
// MARK: - EasyNetDispatcher -
//==========================================

public protocol EasyNetDispatcher {
    func dispatch(request: EasyNetRequestData, onResult:@escaping (Result<Data, Error>) -> Void)
}

public struct URLSessionEasyNetDispatcher: EasyNetDispatcher {
    public static let instance = URLSessionEasyNetDispatcher()
    private init() {}
    
    public func dispatch(request: EasyNetRequestData,
                         onResult: @escaping (Result<Data, Error>) -> Void) {
        
        
        guard let url = URL(string: request.path) else {
            onResult(.failure(EasyNetError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        do {
            if let params = request.params {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        } catch let error {
            onResult(.failure(error))
            return
        }
        
        urlRequest.allHTTPHeaderFields = request.headers ?? [:]
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                onResult(.failure(error))
                return
            }
            
            guard let data = data else {
                onResult(.failure(EasyNetError.noData))
                return
            }
            
            onResult(.success(data))
            
        }.resume()
    }
}


