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
        let session = try? API
            .get
            .session(url: APITests.url)
            .fetch { (result: APIResult<Container>) in
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
        
        XCTAssertNil(error, "search api has return error, (%@)")
        XCTAssertNotNil(value?.books, "search api has failed (may be timeout)")

    }
}
