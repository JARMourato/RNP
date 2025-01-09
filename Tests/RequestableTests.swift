// Copyright © 2022 João Mourato. All rights reserved.

@testable import RNP
import XCTest

final class RequestableTests: XCTestCase {
    // MARK: - Mock Types

    /// A simple MockRequestable to test default behaviors in the Requestable protocol.
    struct MockRequestable: Requestable {
        var headers: Headers
        var method: HTTPMethod
        var parameters: Parameters
        var parameterEncoding: ParameterEncoding

        func buildURLRequest() throws -> URLRequest {
            // For demonstration, we'll just create a URLRequest
            // that applies these properties. In real code, you might
            // do more advanced logic or validation.
            var req = URLRequest(url: URL(string: "https://example.com")!)
            req.headers = headers
            req.httpMethod = method.rawValue
            req.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            return req
        }
    }

    /// A MutableRequestable mock that lets us test the baseURLString property.
    struct MockMutableRequestable: MutableRequestable {
        var headers: Headers = []
        var method: HTTPMethod = .get
        var parameters: Parameters = [:]
        var parameterEncoding: ParameterEncoding = .json
        var baseURLString: String?

        func buildURLRequest() throws -> URLRequest {
            // Build from baseURLString if available
            let urlString = baseURLString ?? "https://fallback.com"

            guard let url = URL(string: urlString), url.scheme != nil, url.host != nil else {
                throw URLError(.badURL)
            }

            var req = URLRequest(url: url)
            req.headers = headers
            req.httpMethod = method.rawValue
            req.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            return req
        }
    }

    /// A basic mock `RequestLoader` for testing asynchronous loading.
    struct MockRequestLoader: RequestLoader {
        let simulatedDataResponse: DataResponse
        let delay: TimeInterval

        func data(for _: Requestable) async throws -> DataResponse {
            // Simulate a short delay
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            return simulatedDataResponse
        }
    }

    /// A basic `RequestBuilder` that appends a header to a `MutableRequestable`.
    struct MockRequestBuilder: RequestBuilder {
        func mutate(_ request: MutableRequestable) -> MutableRequestable {
            var mutable = request
            mutable.headers.insert(.userAgent("MockBuilder/1.0"))
            return mutable
        }
    }

    /// A basic `ResponseModifier` that updates the metrics duration to a fixed value.
    struct MockResponseModifier: ResponseModifier {
        func mutate<R: Requestable>(_ response: Response<R>) -> Response<R> {
            var newMetrics = response.metrics
            newMetrics = Metrics(startDate: newMetrics.startDate, duration: 999)
            return Response(request: response.request, result: response.result, metrics: newMetrics)
        }
    }

    // MARK: - Testing Default `Requestable` Behavior

    func testIsMultipartRequest_DefaultFalse() {
        // Given
        let req = MockRequestable(
            headers: [],
            method: .post,
            parameters: [:],
            parameterEncoding: .json
        )

        // Then
        XCTAssertFalse(req.isMultipartRequest, "No multipart header should result in isMultipartRequest = false.")
    }

    func testIsMultipartRequest_TrueWhenMultipartHeaderPresent() {
        // Given
        let req = MockRequestable(
            headers: [.contentType("multipart/form-data; boundary=abc123")],
            method: .post,
            parameters: [:],
            parameterEncoding: .json
        )

        // Then
        XCTAssertTrue(req.isMultipartRequest, "Content-Type with 'multipart/form-data' should make isMultipartRequest = true.")
    }

    func testRawMethod() {
        // Given
        let req = MockRequestable(
            headers: [],
            method: .put,
            parameters: [:],
            parameterEncoding: .json
        )

        // Then
        XCTAssertEqual(req.rawMethod, "PUT", "rawMethod should reflect the typed HTTPMethod's rawValue.")
    }

    func testDefaultParameterEncodingIsJSON() {
        // Given a minimal Requestable that does NOT override `parameterEncoding`.
        struct DefaultEncodingRequest: Requestable {
            var headers: Headers = []
            var method: HTTPMethod = .get
            var parameters: Parameters = [:]

            func buildURLRequest() throws -> URLRequest {
                // Just build a simple request for testing purposes.
                URLRequest(url: URL(string: "https://example.com")!)
            }
        }

        // When
        let request = DefaultEncodingRequest()

        // Then
        // The extension on Requestable says `parameterEncoding` should default to `.json`
        XCTAssertEqual(request.parameterEncoding, .json, "Default parameterEncoding should be .json if not overridden.")
    }

    func testURLRequestMethodDefaultsToGET() {
        // Given
        var request = URLRequest(url: URL(string: "https://example.com")!)

        // Set the underlying Foundation httpMethod to nil
        request.httpMethod = nil

        // When
        let derivedMethod = request.method

        // Then
        XCTAssertEqual(derivedMethod, .get, "If 'httpMethod' is nil, 'method' should default to GET.")
    }

    // MARK: - Testing `URLRequest` Conformance to `Requestable`

    func testURLRequestHeaders() {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)

        // When
        urlRequest.headers = [.accept("application/json"), .userAgent("TestAgent")]

        // Then
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["User-Agent"], "TestAgent")

        // Reading back
        let readHeaders = urlRequest.headers
        XCTAssertTrue(readHeaders.contains(.accept("application/json")))
        XCTAssertTrue(readHeaders.contains(.userAgent("TestAgent")))
    }

    func testURLRequestMethod() {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)

        // When
        urlRequest.httpMethod = "PATCH"

        // Then
        XCTAssertEqual(urlRequest.method.rawValue, "PATCH")

        // If we clear it
        urlRequest.httpMethod = nil
        XCTAssertEqual(urlRequest.method, .get, "Should default to GET if nil.")
    }

    func testURLRequestParameters() throws {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        let params: Parameters = ["key": "value", "num": 42]

        // When
        urlRequest.parameters = params

        // Then
        let readParams = urlRequest.parameters
        XCTAssertEqual(readParams["key"] as? String, "value")
        XCTAssertEqual(readParams["num"] as? Int, 42)
    }

    func testParametersWhenHTTPBodyIsNil() {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        // httpBody is implicitly nil here, but we'll be explicit
        urlRequest.httpBody = nil

        // When
        let parameters = urlRequest.parameters

        // Then
        XCTAssertTrue(parameters.isEmpty, "If httpBody is nil, parameters should be an empty dictionary.")
    }

    func testParametersWhenHTTPBodyIsInvalidJSON() {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        // Put some data that isn’t valid JSON (or valid JSON but not a dictionary)
        urlRequest.httpBody = Data("Not valid JSON".utf8)

        // When
        let parameters = urlRequest.parameters

        // Then
        XCTAssertTrue(parameters.isEmpty, "If the httpBody cannot be decoded as [String: Any], parameters should be [:].")
    }

    func testURLRequestIsMultipartRequest() {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        XCTAssertFalse(urlRequest.isMultipartRequest)

        // When
        urlRequest.headers = [.contentType("multipart/form-data; boundary=xyz")]

        // Then
        XCTAssertTrue(urlRequest.isMultipartRequest)
    }

    func testURLRequestBuildMethod() throws {
        // Given
        var urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        urlRequest.httpMethod = "POST"
        urlRequest.headers = [.authorization("Bearer 123")]
        urlRequest.parameters = ["foo": "bar"]

        // When
        let built = try urlRequest.buildURLRequest()

        // Then
        XCTAssertEqual(built.httpMethod, "POST")
        XCTAssertEqual(built.allHTTPHeaderFields?["Authorization"], "Bearer 123")

        if let body = built.httpBody,
           let dict = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        {
            XCTAssertEqual(dict["foo"] as? String, "bar")
        } else {
            XCTFail("Body did not contain expected JSON.")
        }
    }

    // MARK: - Testing `MutableRequestable`

    func testMockMutableRequestable() throws {
        // Given
        var mutableReq = MockMutableRequestable()
        mutableReq.baseURLString = "https://custom.com/path"
        mutableReq.method = .delete
        mutableReq.parameters = ["customKey": "customValue"]

        // When
        let built = try mutableReq.buildURLRequest()

        // Then
        XCTAssertEqual(built.url?.absoluteString, "https://custom.com/path")
        XCTAssertEqual(built.httpMethod, "DELETE")
        let decoded = try XCTUnwrap(built.httpBody)
        let decodedDict = try XCTUnwrap(
            (try? JSONSerialization.jsonObject(with: decoded)) as? [String: Any]
        )
        XCTAssertEqual(decodedDict["customKey"] as? String, "customValue")
    }

    func testMockMutableRequestableBadURL() {
        // Given
        var mutableReq = MockMutableRequestable()
        mutableReq.baseURLString = "://"

        // Then
        XCTAssertThrowsError(try mutableReq.buildURLRequest(), "Should throw when the baseURLString is invalid.")
    }

    // MARK: - Testing `RequestLoader`

    func testRequestLoaderData() async throws {
        // Given
        let loader = MockRequestLoader(
            simulatedDataResponse: (Data("FakeData".utf8), URLResponse()),
            delay: 0.1
        )
        let request = MockRequestable(
            headers: [.cacheControl("no-cache")],
            method: .get,
            parameters: [:],
            parameterEncoding: .json
        )

        // When
        let dataResponse = try await loader.data(for: request)

        // Then
        XCTAssertEqual(String(data: dataResponse.data, encoding: .utf8), "FakeData")
    }

    func testRequestLoaderResponseWithMetrics() async throws {
        // Given
        let loader = MockRequestLoader(
            simulatedDataResponse: (Data("HelloWorld".utf8), URLResponse()),
            delay: 0.05
        )
        let request = MockRequestable(
            headers: [],
            method: .post,
            parameters: ["test": true],
            parameterEncoding: .json
        )

        // When
        let start = Date()
        let response = try await loader.response(for: request)
        let end = Date()

        // Then
        XCTAssertEqual(String(data: response.result.data, encoding: .utf8), "HelloWorld")
        // The metrics duration should reflect at least 0.05s delay
        let elapsed = end.timeIntervalSince(start)
        XCTAssertGreaterThanOrEqual(elapsed, 0.05, "Should reflect at least the simulated delay.")

        // The request in the response should match
        XCTAssertEqual(response.request.method, .post)
        XCTAssertEqual(response.request.parameters["test"] as? Bool, true)
    }

    // MARK: - Testing `RequestBuilder` & `ResponseModifier`

    func testRequestBuilderMutate() throws {
        // Given
        let builder = MockRequestBuilder()
        let mutableReq = MockMutableRequestable()

        // When
        let result = builder.mutate(mutableReq)

        // Then
        XCTAssertTrue(result.headers.contains(.userAgent("MockBuilder/1.0")), "Should have inserted a User-Agent header.")
    }

    func testResponseModifierMutate() throws {
        // Given
        let modifier = MockResponseModifier()
        let metrics = Metrics(startDate: Date(), duration: 1)
        let dataResponse: DataResponse = (Data(), URLResponse())
        let request = MockRequestable(
            headers: [],
            method: .get,
            parameters: [:],
            parameterEncoding: .json
        )
        let originalResponse = Response(request: request, result: dataResponse, metrics: metrics)

        // When
        let modified = modifier.mutate(originalResponse)

        // Then
        XCTAssertEqual(modified.metrics.duration, 999, "Should have overridden the duration to 999.")
        XCTAssertEqual(modified.request.method, .get, "Everything else should remain unchanged.")
    }
}

// MARK: - MockNilRequest

struct MockNilRequest: Requestable {
    var headers: Headers = []
    // We manually store `httpMethod` in an optional so it really can be `nil`.
    var _httpMethod: String?

    var method: HTTPMethod {
        HTTPMethod(rawValue: _httpMethod ?? "GET")
    }

    var parameters: Parameters = [:]
    var parameterEncoding: ParameterEncoding = .json

    func buildURLRequest() throws -> URLRequest {
        URLRequest(url: URL(string: "https://example.com")!)
    }

    // Expose a function to set the method to nil:
    mutating func setMethodToNil() {
        _httpMethod = nil
    }
}

final class MockNilRequestTests: XCTestCase {
    func testNilHTTPMethodDefaultsToGET() {
        var request = MockNilRequest()

        // Intentionally set it to something else, then to nil
        request._httpMethod = "POST"
        request.setMethodToNil()

        XCTAssertEqual(request.method, .get)
    }
}
