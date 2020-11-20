//
//  UnsplashModel.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/18.
//

import Foundation

struct UnsplashUser: Decodable {
    struct ProfileImage: Decodable {
        let small: URL
        let medium: URL
        let large: URL
    }
    
    struct Link: Decodable {
        let `self`: URL
        let html: URL
        let photos: URL
        let likes: URL
        let portfolio: URL
    }
    
    let id: String
    let username: String
    let name: String
    let portfolioUrl: URL?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let instagramUsername: String?
    let twitterUsername: String?
    let profileImage: ProfileImage
    let links: Link
}

extension UnsplashUser: Equatable {
    static func ==(lhs: UnsplashUser, rhs: UnsplashUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UnsplashPhoto: Decodable {
    struct Color: Decodable {
        let string: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.string = try container.decode(String.self)
        }
    }
    
    struct Collection: Decodable {
        let id: Int
        let title: String
        let publishedAt: Date
        let lastCollectedAt: Date
        let updatedAt: Date
        let coverPhoto: URL?
        let user: UnsplashUser?
    }
    
    struct URLContainer: Decodable {
        let raw: URL
        let full: URL
        let regular: URL
        let small: URL
        let thumb: URL
    }
    
    struct Link: Decodable {
        let `self`: URL
        let html: URL
        let download: URL
        let downloadLocation: URL
    }
    
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let width: Int
    let height: Int
    let color: Color
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let altDescription: String?
    let user: UnsplashUser
    let sponser: UnsplashUser?
    let currentUserCollections: [Collection]
    let urls: URLContainer
    let links: Link
    
    // Detail for single photo API
    
    struct EXIF: Decodable {
        let make: String?
        let model: String?
        let exposureTime: String?
        let aperture: String?
        let focal_length: String?
        let iso: Int?
    }
    
    struct Location: Decodable {
        struct Coordinate: Decodable {
            let latitude: Double
            let longitude: Double
        }
        let city: String?
        let country: String?
        let postion: Coordinate?
    }
    
    struct Tag: Decodable {
        let title: String
    }
    
    let exif: EXIF?
    let location: Location?
    let tag: [Tag]?
}

extension UnsplashPhoto: Equatable {
    static func ==(lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UnsplashPhotoContainer: Decodable {
    let total: Int
    let totalPages: Int
    
    let results: [UnsplashPhoto]
}
