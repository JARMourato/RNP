// Copyright © 2022 João Mourato. All rights reserved.

@testable import RNP
import XCTest

final class RNPTests: XCTestCase {
    // MARK: Requestable

    func test_urlRequest_make() throws {
        // Given
        let urlRequest = URLRequest(url: URL(string: "www.google.com")!)
        // When
        let requestable: Requestable = urlRequest
        // Then
        XCTAssertEqual(urlRequest, try requestable.buildURLRequest())
    }
}
