//
//  API.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import Foundation

protocol URLConvertable {
    var asURL: URL? { get }
}

protocol APIQuery {
    var asQuery: String? { get }
}

protocol APIHeader {
    var asHeader: [String : String] { get }
}

protocol APIBody {
    func asBody(with encoder: APIEncoder) throws -> Data?
}

protocol APIEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

protocol APIDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

protocol APISession {
    var url: URL { get }
    var scheme: String { get }
    var header: APIHeader? { get }
    var body: APIBody? { get }
    
    var timeInterval: TimeInterval { get }
    var encoder: APIEncoder { get }
    var decoder: APIDecoder { get }
    
    func query(_ query: APIQuery) -> Self
    func header(_ header: APIHeader) -> Self
    func body(_ body: APIBody) -> Self

    func timeInterval(_ timeInterval: TimeInterval) -> Self
    
    func encoder(_ encoder: APIEncoder) -> Self
    func decoder(_ decoder: APIDecoder) -> Self
    
    func fetch<T>(_ handler: @escaping (APIResult<T>) -> Void) -> Self where T: Decodable
    func cancel() -> Self
}

fileprivate final class _APISession: APISession {
    static var defaultTimeInterval = 15.0
    
    var components: URLComponents
    let scheme: String
    var header: APIHeader?
    var body: APIBody?
    
    var timeInterval: TimeInterval = _APISession.defaultTimeInterval
    var encoder: APIEncoder = JSONEncoder()
    var decoder: APIDecoder = JSONDecoder()
    
    var task: URLSessionTask?
    
    init(url: URLConvertable, scheme: String) throws {
        guard let url = url.asURL, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw APIError.urlConvertFailure
        }
        
        self.components = components
        self.scheme = scheme
    }
    
    deinit {
        _ = self.cancel()
    }
    
    var url: URL {
        return self.components.url!
    }
    
    func query(_ query: APIQuery) -> Self {
        self.components.query = query.asQuery
        return self
    }
    func header(_ header: APIHeader) -> Self {
        self.header = header
        return self
    }
    func body(_ body: APIBody) -> Self {
        self.body = body
        return self
    }
    
    func timeInterval(_ timeInterval: TimeInterval) -> Self {
        self.timeInterval = timeInterval
        return self
    }
    
    func encoder(_ encoder: APIEncoder) -> Self {
        self.encoder = encoder
        return self
    }
    func decoder(_ decoder: APIDecoder) -> Self {
        self.decoder = decoder
        return self
    }
    
    func fetch<T>(_ handler: @escaping (APIResult<T>) -> Void) -> Self where T: Decodable {
        guard let url = components.url else {
            handler(.failure(error: APIError.urlConvertFailure, response: nil, data: nil))
            return self
        }
        
        do {
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: self.timeInterval)
            request.allHTTPHeaderFields = self.header?.asHeader
            request.httpBody = try self.body?.asBody(with: self.encoder)
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self, let data = data else {
                    handler(.failure(error: error ?? APIError.nullReturn, response: response, data: nil))
                    return
                }

                #if DEBUG
                self.log(message: "url: \(url)")
                if let response = response as? HTTPURLResponse {
                    self.log(message: "response: \(response)")
                }
                if let received = String(data: data, encoding: .utf8) {
                    self.log(message: "received: \(received)")
                }
                #endif

                if let httpResponse = response as? HTTPURLResponse, let error = httpResponse.asError {
                    handler(.failure(error: error, response: response, data: data))
                    return
                }

                do {
                    let value: T = try data.decode(with: self.decoder)
                    handler(.success(value: value, response: response, data: data))
                } catch let exception {
                    handler(.failure(error: exception, response: response, data: data))
                }
            }
            
            self.task = task
            task.resume()
        } catch let exception {
            handler(.failure(error: exception, response: nil, data: nil))
        }
        
        return self
    }
    
    func cancel() -> Self {
        self.task?.cancel()
        return self
    }
}

extension Data {
    func decode<T>(with decoder: APIDecoder, type: T.Type = T.self) throws -> T where T: Decodable {
        if type == Data.self {
            return self as! T
        } else {
            return try decoder.decode(type, from: self)
        }
    }
}

extension _APISession: Loggable { }

enum API: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    func session(url: URLConvertable) throws -> APISession {
        return try _APISession(url: url, scheme: self.rawValue)
    }
}

enum APIResult<T> where T: Decodable {
    case success(value: T, response: URLResponse?, data: Data)
    case failure(error: Error, response: URLResponse?, data: Data?)
}

extension APIResult {
    var value: T? {
        switch self {
            case .success(let value, _, _):
                return value
            default:
                return nil
        }
    }
    
    var error: Error? {
        switch self {
            case .failure(let error, _, _):
                return error
            default:
                return nil
        }
    }
    
    var response: URLResponse? {
        switch self {
            case .success(_, let response, _), .failure(_, let response, _):
                return response
        }
    }
    
    var data: Data? {
        switch self {
            case .success(_, _, let data):
                return data
            case .failure(_, _, let data):
                return data
        }
    }
}

enum APIError: Error {
    case urlConvertFailure
    case nullReturn
    case responseError(statusCode: Int, localizedDescription: String)
}
