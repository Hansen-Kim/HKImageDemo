//
//  Unsplash.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import Foundation

private protocol UnsplashSessionBuilder {
    var session: APISession { get }
}

enum Unsplash {
    private struct Constants {
        static let accessKey = "o_0grZU_jpCWnV_Noe8RsG9mVVGP3uN2S6a4auG_bww"
        static let secretKey = "LZoJRVkCPBYaAmHN5J-tHnsCsqtxnXnUXL46gN_RRFI"
        
        static let url = URL(string: "https://api.unsplash.com")!
        static let acceptVersion = "v1"
        static let authorization = "Client-ID \(Constants.accessKey)"
        
        static let defaultHeader = [
            "Accept-Version" : Constants.acceptVersion,
            "Authorization" : Constants.authorization
        ]
    }
    
    case photoList(page: Int = 1, perPage: Int = 10, order: Order = .latest)
    case singlePhoto(id: String)
    case searchPhoto(query: String, page: Int = 1, perPage: Int = 10, order: Order = .latest)
    case random
    
    enum Order: String, Encodable, CustomStringConvertible, Hashable {
        case latest
        case oldest
        case popular
    }
    
    func session() throws -> APISession {
        let session: APISession
        switch self {
            case .photoList(let page, let perPage, let order):
                session = try PhotoListSessionBuilder(with: page, perPage: perPage, by: order).session
            case .singlePhoto(let id):
                session = try SinglePhotoSessionBuilder(with: id).session
            case .searchPhoto(let query, let page, let perPage, let order):
                session = try SearchPhotoSessionBuilder(with: query, page: page, perPage: perPage, by: order).session
            case .random:
                session = try RandomPhotoSessionBuilder().session
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session.decoder(decoder)
    }
    
    private struct PhotoListSessionBuilder: UnsplashSessionBuilder {
        struct Constants {
            static let path = "photos"
        }
        enum QueryKey: String, CustomStringConvertible, Hashable {
            case page = "page"
            case perPage = "per_page"
            case order = "order_by"
        }

        let session: APISession
        
        init(with page: Int, perPage: Int, by order: Order) throws {
            let query: [QueryKey: String] = [
                QueryKey.page : page.description,
                QueryKey.perPage : perPage.description,
                QueryKey.order : order.description
            ]
            
            self.session = try API
                .get
                .session(url: Unsplash.Constants.url.appendingPathComponent(Constants.path))
                .header(Unsplash.Constants.defaultHeader)
                .query(query)
        }
    }
    
    private struct SinglePhotoSessionBuilder: UnsplashSessionBuilder {
        struct Constants {
            static let path = "photos"
        }

        let session: APISession
        
        init(with id: String) throws {
            self.session = try API
                .get
                .session(url: Unsplash.Constants.url.appendingPathComponent(Constants.path).appendingPathComponent(id))
                .header(Unsplash.Constants.defaultHeader)
        }
    }
    
    private struct SearchPhotoSessionBuilder: UnsplashSessionBuilder {
        struct Constants {
            static let path = "search/photos"
        }
        enum QueryKey: String, CustomStringConvertible, Hashable {
            case query = "query"
            case page = "page"
            case perPage = "per_page"
            case order = "order_by"
        }

        let session: APISession
        
        init(with query: String, page: Int, perPage: Int, by order: Order) throws {
            let query: [QueryKey: String] = [
                QueryKey.query : query,
                QueryKey.page : page.description,
                QueryKey.perPage : perPage.description,
                QueryKey.order : order.description
            ]
            
            self.session = try API
                .get
                .session(url: Unsplash.Constants.url.appendingPathComponent(Constants.path))
                .header(Unsplash.Constants.defaultHeader)
                .query(query)
        }
    }
    
    private struct RandomPhotoSessionBuilder: UnsplashSessionBuilder {
        struct Constants {
            static let path = "photos/random"
        }

        let session: APISession
        
        init() throws {
            self.session = try API
                .get
                .session(url: Unsplash.Constants.url.appendingPathComponent(Constants.path))
                .header(Unsplash.Constants.defaultHeader)
        }
    }
}

enum UnsplashError: Error {
    case errorResult(strings: [String])
}

struct UnsplashErrorResult: Decodable {
    let errors: [String]
    
    var asError: Error {
        return UnsplashError.errorResult(strings: self.errors)
    }
}

extension APISession {
    func unsplashfetch<T>(_ hander: @escaping (APIResult<T>) -> Void) -> Self where T: Decodable {
        return self.fetch { (result: APIResult<T>) in
            if let data = result.data, let errorResult = try? self.decoder.decode(UnsplashErrorResult.self, from: data) {
                hander(.failure(error: errorResult.asError, response: result.response, data: result.data))
                return
            }
            
            hander(result)
        }
    }
}
