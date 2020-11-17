//
//  Unsplash.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import Foundation

fileprivate struct UnsplashConstants {
    static let accessKey = "o_0grZU_jpCWnV_Noe8RsG9mVVGP3uN2S6a4auG_bww"
    static let secretKey = "LZoJRVkCPBYaAmHN5J-tHnsCsqtxnXnUXL46gN_RRFI"
    
    static let url = URL(string: "https://api.unsplash.com")!
    static let acceptVersion = "v1"
    static let authorization = "Client-ID \(UnsplashConstants.accessKey)"
    
    static let defaultHeader = [
        "Accept-Version" : UnsplashConstants.acceptVersion,
        "Authorization" : UnsplashConstants.authorization
    ]
}

enum Unsplash {
    case photoList(page: Int = 1, perPage: Int = 10, orderBy: OrderBy = .latest)
    case singlePhoto(id: String)
    case searchPhoto(query: String, page: Int = 1, perPage: Int = 10, orderBy: OrderBy = .latest)
    
    enum OrderBy: String {
        case latest
        case oldest
        case popular
    }
}
