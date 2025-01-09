// Copyright © 2025 JARMourato All rights reserved.

@testable import RNP // Replace "RNP" with your actual module name
import XCTest

final class HTTPTypesTests: XCTestCase {
    // MARK: - ParameterEncoding Tests

    func testParameterEncodingPredefinedValues() {
        // Given
        let jsonEncoding = ParameterEncoding.json
        let urlEncoding = ParameterEncoding.url

        // Then
        XCTAssertEqual(jsonEncoding.rawValue, "application/json")
        XCTAssertEqual(urlEncoding.rawValue, "application/x-www-form-urlencoded")
    }

    func testParameterEncodingCustomValue() {
        // Given
        let customRawValue = "application/custom-encoding"

        // When
        let customEncoding = ParameterEncoding(rawValue: customRawValue)

        // Then
        XCTAssertEqual(customEncoding.rawValue, customRawValue)
        XCTAssertNotEqual(customEncoding, .json)
        XCTAssertNotEqual(customEncoding, .url)
    }

    func testParameterEncodingEquality() {
        // Given
        let encoding1 = ParameterEncoding.json
        let encoding2 = ParameterEncoding(rawValue: "application/json")
        let encoding3 = ParameterEncoding.url

        // Then
        XCTAssertEqual(encoding1, encoding2, "Identical rawValues should be equal")
        XCTAssertNotEqual(encoding1, encoding3, "Different rawValues should not be equal")
    }

    // MARK: - HTTPMethod Tests

    func testHTTPMethodsPredefined() {
        // Given & When
        let methods = [
            HTTPMethod.connect.rawValue,
            HTTPMethod.delete.rawValue,
            HTTPMethod.get.rawValue,
            HTTPMethod.options.rawValue,
            HTTPMethod.patch.rawValue,
            HTTPMethod.post.rawValue,
            HTTPMethod.put.rawValue,
            HTTPMethod.trace.rawValue,
        ]

        // Then
        XCTAssertEqual(methods, [
            "CONNECT",
            "DELETE",
            "GET",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT",
            "TRACE",
        ], "HTTPMethod raw values should match the expected strings.")
    }

    func testHTTPMethodCustomInitialization() {
        // Given
        let customRawValue = "CUSTOM"

        // When
        let customMethod = HTTPMethod(rawValue: customRawValue)

        // Then
        XCTAssertEqual(customMethod.rawValue, customRawValue)
        XCTAssertNotEqual(customMethod, HTTPMethod.get)
    }

    func testHTTPMethodEquality() {
        // Given
        let method1 = HTTPMethod.get
        let method2 = HTTPMethod(rawValue: "GET")
        let method3 = HTTPMethod.put

        // Then
        XCTAssertEqual(method1, method2, "Identical rawValues should be equal.")
        XCTAssertNotEqual(method2, method3, "Different rawValues should not be equal.")
    }

    // MARK: - HTTPHeader Tests

    func testHTTPHeaderStaticMethods() {
        // Each static func on HTTPHeader:
        let acceptHeader = HTTPHeader.accept("application/json")
        let acceptEncodingHeader = HTTPHeader.acceptEncoding("gzip")
        let acceptLanguageHeader = HTTPHeader.acceptLanguage("en-US")
        let authorizationHeader = HTTPHeader.authorization("Basic 123")
        let authorizationBearerHeader = HTTPHeader.authorizationBearer("someToken")
        let cacheControlHeader = HTTPHeader.cacheControl("no-cache")
        let contentLengthHeader = HTTPHeader.contentLength(256)
        let contentTypeHeader = HTTPHeader.contentType("application/json")
        let cookieHeader = HTTPHeader.cookie("sessionid=abc123")
        let hostHeader = HTTPHeader.host("example.com")
        let ifMatchHeader = HTTPHeader.ifMatch("W/\"123abc\"")
        let ifModifiedSinceHeader = HTTPHeader.ifModifiedSince("Sat, 29 Oct 1994 19:43:31 GMT")
        let ifNoneMatchHeader = HTTPHeader.ifNoneMatch("W/\"xyz789\"")
        let ifUnmodifiedSinceHeader = HTTPHeader.ifUnmodifiedSince("Sat, 29 Oct 1994 19:43:31 GMT")
        let originHeader = HTTPHeader.origin("https://example.com")
        let refererHeader = HTTPHeader.referer("https://google.com")
        let userAgentHeader = HTTPHeader.userAgent("MyTestAgent/1.0")

        // Verify them:
        XCTAssertEqual(acceptHeader.key, "Accept")
        XCTAssertEqual(acceptHeader.value, "application/json")

        XCTAssertEqual(acceptEncodingHeader.key, "Accept-Encoding")
        XCTAssertEqual(acceptEncodingHeader.value, "gzip")

        XCTAssertEqual(acceptLanguageHeader.key, "Accept-Language")
        XCTAssertEqual(acceptLanguageHeader.value, "en-US")

        XCTAssertEqual(authorizationHeader.key, "Authorization")
        XCTAssertEqual(authorizationHeader.value, "Basic 123")

        XCTAssertEqual(authorizationBearerHeader.key, "Authorization")
        XCTAssertEqual(authorizationBearerHeader.value, "Bearer someToken")

        XCTAssertEqual(cacheControlHeader.key, "Cache-Control")
        XCTAssertEqual(cacheControlHeader.value, "no-cache")

        XCTAssertEqual(contentLengthHeader.key, "Content-Length")
        XCTAssertEqual(contentLengthHeader.value, "256")

        XCTAssertEqual(contentTypeHeader.key, "Content-Type")
        XCTAssertEqual(contentTypeHeader.value, "application/json")

        XCTAssertEqual(cookieHeader.key, "Cookie")
        XCTAssertEqual(cookieHeader.value, "sessionid=abc123")

        XCTAssertEqual(hostHeader.key, "Host")
        XCTAssertEqual(hostHeader.value, "example.com")

        XCTAssertEqual(ifMatchHeader.key, "If-Match")
        XCTAssertEqual(ifMatchHeader.value, "W/\"123abc\"")

        XCTAssertEqual(ifModifiedSinceHeader.key, "If-Modified-Since")
        XCTAssertEqual(ifModifiedSinceHeader.value, "Sat, 29 Oct 1994 19:43:31 GMT")

        XCTAssertEqual(ifNoneMatchHeader.key, "If-None-Match")
        XCTAssertEqual(ifNoneMatchHeader.value, "W/\"xyz789\"")

        XCTAssertEqual(ifUnmodifiedSinceHeader.key, "If-Unmodified-Since")
        XCTAssertEqual(ifUnmodifiedSinceHeader.value, "Sat, 29 Oct 1994 19:43:31 GMT")

        XCTAssertEqual(originHeader.key, "Origin")
        XCTAssertEqual(originHeader.value, "https://example.com")

        XCTAssertEqual(refererHeader.key, "Referer")
        XCTAssertEqual(refererHeader.value, "https://google.com")

        XCTAssertEqual(userAgentHeader.key, "User-Agent")
        XCTAssertEqual(userAgentHeader.value, "MyTestAgent/1.0")
    }

    func testHTTPHeaderDirectInitialization() {
        // Given
        let header = HTTPHeader(key: "X-Custom-Header", value: "CustomValue")

        // Then
        XCTAssertEqual(header.key, "X-Custom-Header")
        XCTAssertEqual(header.value, "CustomValue")
    }

    func testHTTPHeaderEquality() {
        // Given
        let header1 = HTTPHeader(key: "Content-Type", value: "application/json")
        let header2 = HTTPHeader.contentType("application/json")
        let header3 = HTTPHeader.contentType("text/plain")

        // Then
        XCTAssertEqual(header1, header2, "Identical headers should be equal.")
        XCTAssertNotEqual(header1, header3, "Different values should not be equal.")
    }

    func testHTTPHeaderHashableBehavior() {
        // Headers are `Hashable`, so we can store them in a `Set` or use them as dictionary keys.
        // We’ll confirm correct behavior when duplicates are added.

        // Given
        let header1 = HTTPHeader.userAgent("MyApp/1.0")
        let header2 = HTTPHeader.userAgent("MyApp/1.0") // Same as header1
        let header3 = HTTPHeader.userAgent("MyApp/2.0") // Different value

        // When
        let setOfHeaders: Set<HTTPHeader> = [header1, header2, header3]

        // Then
        XCTAssertEqual(setOfHeaders.count, 2, "Duplicate headers should collapse into one in a Set.")
        XCTAssertTrue(setOfHeaders.contains(header1))
        XCTAssertTrue(setOfHeaders.contains(header3))
    }
}
