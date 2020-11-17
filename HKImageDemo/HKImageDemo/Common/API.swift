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
    var asHeader: [String : CustomStringConvertible] { get }
}

protocol APIBody {
    var asBody: Data? { get }
}

protocol APIDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

protocol APISession {
    func query(_ query: APIQuery) -> Self
    func header(_ header: APIHeader) -> Self
    func body(_ body: APIBody) -> Self

    func timeInterval(_ timeInterval: TimeInterval) -> Self
    
    func decoder(_ decoder: APIDecoder) -> Self
    
    func fetch<T>(_ handler: @escaping (URLResponse?, APIResult<T>) -> Void) -> Self where T: Decodable
    func cancel() -> Self
}

fileprivate final class _APISession: APISession {
    static var defaultTimeInterval = 15.0
    
    var components: URLComponents
    var scheme: String
    var header: APIHeader?
    var body: APIBody?
    
    var timeInterval: TimeInterval = _APISession.defaultTimeInterval
    var decoder: APIDecoder = JSONDecoder()
    
    var task: URLSessionTask?
    
    init(url: URLConvertable, scheme: String) throws {
        guard let url = url.asURL, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw APIError.urlConvertFailure
        }
        
        self.components = components
        self.scheme = scheme
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
    
    func decoder(_ decoder: APIDecoder) -> Self {
        self.decoder = decoder
        return self
    }
    
    func fetch<T>(_ handler: @escaping (URLResponse?, APIResult<T>) -> Void) -> Self where T: Decodable {
        guard let url = components.url else {
            handler(nil, .failure(APIError.urlConvertFailure))
            return self
        }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: self.timeInterval)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self, let data = data else {
                handler(response, .failure(error ?? APIError.nullReturn))
                return
            }
            
            do {
                let value = try self.decoder.decode(T.self, from: data)
                handler(response, .success(value))
            } catch let exception {
                handler(response, .failure(exception))
            }
        }
        
        self.task = task
        task.resume()
        
        return self
    }
    
    func cancel() -> Self {
        self.task?.cancel()
        return self
    }
}

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
    case success(T)
    case failure(Error)
}

enum APIError: Error {
    case urlConvertFailure
    case nullReturn
}

extension JSONDecoder: APIDecoder {
    
}

extension String: URLConvertable {
    var asURL: URL? { return URL(string: self) }
}
extension URL: URLConvertable {
    var asURL: URL? { return self }
}
extension URLComponents: URLConvertable {
    var asURL: URL? { return self.url }
}
