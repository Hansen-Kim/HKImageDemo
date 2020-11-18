//
//  UnsplashTests.swift
//  HKImageDemoTests
//
//  Created by 김승한 on 2020/11/18.
//

import XCTest
@testable import HKImageDemo

class UnsplashTests: XCTestCase {
    func testUnsplashPhotoList() throws {
        let semaphore = DispatchSemaphore(value: 0)
        
        var value: [UnsplashPhoto]?
        var error: Error?
        
        let session = try? Unsplash
            .photoList(page: 1, perPage: 50, order: .latest)
            .session().unsplashfetch { (result: APIResult<[UnsplashPhoto]>) in
                switch result {
                    case .success(let aValue, _, _):
                        value = aValue
                    case .failure(let anError, _, _):
                        error = anError
                }
                
                semaphore.signal()
            }
        
        XCTAssertNotNil(session, "session initialize failed")
        
        _ = semaphore.wait(timeout: DispatchTime.now() + 15.0)
        
        XCTAssertNil(error, "unsplash photo list has return error, (%@)")
        XCTAssertNotNil(value, "unsplash photo list has failed (may be timeout)")
        
        
        XCTAssertNoThrow(try {
            guard let id = value?.first?.id else {
                XCTAssert(true, "unsplash photo list is empty")
                return
            }
            try self.testSinglePhoto(with: id)
        }())
    }
    
    func testUnsplashSearchPhotoList() throws {
        let semaphore = DispatchSemaphore(value: 0)
        
        var value: UnsplashPhotoContainer?
        var error: Error?
        
        let session = try? Unsplash
            .searchPhoto(query: "forest", page: 1, perPage: 50, order: .latest)
            .session().unsplashfetch { (result: APIResult<UnsplashPhotoContainer>) in
                switch result {
                    case .success(let aValue, _, _):
                        value = aValue
                    case .failure(let anError, _, _):
                        error = anError
                }
                
                semaphore.signal()
            }
        
        XCTAssertNotNil(session, "session initialize failed")
        
        _ = semaphore.wait(timeout: DispatchTime.now() + 15.0)
        
        XCTAssertNil(error, "unsplash photo list has return error, (%@)")
        XCTAssertNotNil(value?.results, "unsplash photo list has failed (may be timeout)")
        
        
        XCTAssertNoThrow(try {
            guard let id = value?.results.first?.id else {
                XCTAssert(true, "unsplash photo list is empty")
                return
            }
            try self.testSinglePhoto(with: id)
        }())
    }
    
    func testSinglePhoto(with id: String) throws {
        let semaphore = DispatchSemaphore(value: 0)
        var value: UnsplashPhoto?
        var error: Error?
        
        let session = try? Unsplash
            .singlePhoto(id: id)
            .session().unsplashfetch { (result: APIResult<UnsplashPhoto>) in
                switch result {
                    case .success(let aValue, _, _):
                        value = aValue
                    case .failure(let anError, _, _):
                        error = anError
                }
                
                semaphore.signal()
            }
        
        XCTAssertNotNil(session, "session initialize failed")
        
        _ = semaphore.wait(timeout: DispatchTime.now() + 15.0)
        
        XCTAssertNil(error, "unsplash single photo list has return error, (%@)")
        XCTAssertNotNil(value, "unsplash single photo has failed (may be timeout)")
    }
}
