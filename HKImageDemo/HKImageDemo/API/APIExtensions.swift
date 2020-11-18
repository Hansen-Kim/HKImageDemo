//
//  APIExtensions.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import Foundation

extension String: URLConvertable {
    var asURL: URL? { return URL(string: self) }
}
extension URL: URLConvertable {
    var asURL: URL? { return self }
}
extension URLComponents: URLConvertable {
    var asURL: URL? { return self.url }
}

extension Array: APIQuery where Element == URLQueryItem {
    var asQuery: String? { return self.count > 0 ? self.map({ "\($0.name)=\($0.value ?? "")" }).joined(separator: "&") : nil }
}
extension Dictionary: APIQuery where Key: CustomStringConvertible, Value: CustomStringConvertible {
    var asQuery: String? { return self.count > 0 ? self.map({ "\($0.key.description)=\($0.value.description)"}).joined(separator: "&") : nil }
}

extension Array: APIHeader where Element == URLQueryItem {
    var asHeader: [String : String] {
        return self.reduce(into: [:]) { (result, item) in
            guard let value = item.value else { return }
            result[item.name] = value
        }
    }
}
extension Dictionary: APIHeader where Key: CustomStringConvertible, Value: CustomStringConvertible {
    var asHeader: [String : String] { return self.reduce(into: [:]) { (result, item) in result[item.key.description] = item.value.description } }
}

extension Encodable where Self: APIBody {
    func asBody(with encoder: APIEncoder) throws -> Data? {
        return try encoder.encode(self)
    }
}

extension Data: APIBody {
    func asBody(with encoder: APIEncoder) throws -> Data? {
        return self
    }
}

extension JSONEncoder: APIEncoder {
    
}

extension JSONDecoder: APIDecoder {
    
}

extension HTTPURLResponse {
    enum StatusCodePrefix: Int {
        case success = 2
        case informationError = 4
        case serverError = 5
    }
    
    var asError: APIError? {
        switch StatusCodePrefix(rawValue: self.statusCode / 100) {
            case .informationError, .serverError:
                return APIError.responseError(statusCode: self.statusCode,
                                              localizedDescription: HTTPURLResponse.localizedString(forStatusCode: self.statusCode))
            default:
                return nil
        }
    }
}
