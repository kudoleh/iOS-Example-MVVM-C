//
//  NetworkService.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

extension URLSessionDataTask: Cancellable { }

public protocol NetworkServiceInterface {
    
    func request(endpoint: Requestable, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable?
}

public enum NetworkError: Error {
    case errorStatusCode(statusCode: Int)
    case notConnected
    case cancelled
    case urlGeneration
    case requestError(Error?)
}

extension NetworkError {
    var isNotFoundError: Bool { return hasCodeError(404) }
    
    func hasCodeError(_ codeError: Int) -> Bool {
        switch self {
        case let .errorStatusCode(code):
            return code == codeError
        default: return false
        }
    }
}

public protocol NetworkSession {
    func loadData(from request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSession {
    public func loadData(from request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
}

// MARK: - Implementation

public class NetworkService {
    
    private let session: NetworkSession
    private let config: NetworkConfigurable
    
    public init(session: NetworkSession, config: NetworkConfigurable) {
        self.session = session
        self.config = config
    }
    
    private func request(request: URLRequest, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable {

        let sessionDataTask = session.loadData(from: request) { (data, response, requestError) in
            var error: NetworkError
            if let requestError = requestError {
                
                if let response = response as? HTTPURLResponse, (400..<600).contains(response.statusCode) {
                    error = .errorStatusCode(statusCode: response.statusCode)
                    Logger.log(statusCode: response.statusCode)
                } else if requestError._code == NSURLErrorNotConnectedToInternet {
                    error = .notConnected
                } else if requestError._code == NSURLErrorCancelled {
                    error = .cancelled
                } else {
                    error = .requestError(requestError)
                }
                Logger.log(error: requestError)
                completion(.failure(error))
            }
            else {
                Logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        sessionDataTask.resume()
        
        Logger.log(request: request)
        
        return sessionDataTask
    }
}

extension NetworkService: NetworkServiceInterface {
    
    public func request(endpoint: Requestable, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(NetworkError.urlGeneration))
            return nil
        }
    }
}

// MARK: - Log
class Logger {
    static func log(request: URLRequest) {
        #if DEBUG
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String:AnyObject]) as [String : AnyObject]??) {
            print("body: \(String(describing: result))")
        }
        if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
        #endif
    }
    
    static func log(responseData data: Data?, response: URLResponse?) {
        #if DEBUG
        guard let data = data else { return }
        if let dataDict =  try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("responseData: \(String(describing: dataDict))")
        }
        #endif
    }
    
    static func log(error: Error) {
        #if DEBUG
        print("error: \(error)")
        #endif
    }
    
    static func log(statusCode: Int) {
        #if DEBUG
        print("status code: \(statusCode)")
        #endif
    }
}

