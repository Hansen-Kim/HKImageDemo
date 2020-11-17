//
//  APITests.swift
//  HKImageDemoTests
//
//  Created by 김승한 on 2020/11/17.
//

import XCTest
@testable import HKImageDemo

class APITests: XCTestCase {
    static let url = "https://api.itbook.store/1.0/search/book/1"
    struct Book: Decodable {
        let title: String
        let subtitle: String
        let isbn13: String
        let price: String
        let image: URL
        let url: URL
    }
    
    struct Container: Decodable {
        let total: String
        let page: String
        let books: [Book]
    }
    
    func testAPI() throws {
        let semaphore = DispatchSemaphore(value: 0)
        var value: Container?
        var error: Error?
        let session: APISession? = try? API.get.session(url: APITests.url)
        
        XCTAssertNotNil(session, "session initialize failed")
        
        _ = session?.fetch { [weak self] (_, result: APIResult<Container>) in
            guard self != nil else {
                XCTFail("self is deinitialized")
                semaphore.signal()
                return
            }
            
            switch result {
                case .success(let aValue):
                    value = aValue
                case .failure(let anError):
                    error = anError
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + 15.0)
        
        XCTAssertNil(error, "search api has return error, (%@)")
        XCTAssertNotNil(value?.books, "search api has failed (may be timeout)")

    }
}
