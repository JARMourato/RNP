// Copyright © 2025 JARMourato All rights reserved.

@testable import RNP
import XCTest

final class DataTypesTests: XCTestCase {
    // MARK: - Metrics Tests

    func testMetricsInitialization() {
        // Given
        let startDate = Date()
        let duration: TimeInterval = 1.23

        // When
        let metrics = Metrics(startDate: startDate, duration: duration)

        // Then
        XCTAssertEqual(metrics.startDate, startDate, "Metrics startDate should match.")
        XCTAssertEqual(metrics.duration, duration, "Metrics duration should match.")
    }

    // MARK: - File Tests

    func testFileInitialization() {
        // Given
        let fileData = "file content".data(using: .utf8)!
        let metadata: Parameters = ["key": "value"]
        let filename = "testfile.txt"
        let mimeType = "text/plain"

        // When
        let file = File(data: fileData, fileData: metadata, filename: filename, mimetype: mimeType)

        // Then
        XCTAssertEqual(file.data, fileData, "File data should match the provided data.")
        XCTAssertEqual(file.fileData?["key"] as? String, "value", "File metadata should match the provided dictionary.")
        XCTAssertEqual(file.filename, filename, "Filename should match.")
        XCTAssertEqual(file.mimetype, mimeType, "MIME type should match.")
    }

    // MARK: - Response Tests

    // To test `Response<Request: Requestable>`, we need a simple mock `Requestable`.
    // For the sake of example, we'll create a minimal mock here.
    struct MockRequest: Requestable {
        var headers: Headers = []
        var method: HTTPMethod = .get
        var parameters: Parameters = [:]

        func buildURLRequest() throws -> URLRequest {
            // Return a simple URLRequest for testing
            URLRequest(url: URL(string: "https://example.com")!)
        }
    }

    func testResponseInitialization() {
        // Given
        let startDate = Date()
        let duration: TimeInterval = 2.5
        let metrics = Metrics(startDate: startDate, duration: duration)

        let dataResponse: DataResponse = (data: Data("TestData".utf8),
                                          urlResponse: URLResponse(url: URL(string: "https://example.com")!,
                                                                   mimeType: nil,
                                                                   expectedContentLength: 0,
                                                                   textEncodingName: nil))

        let request = MockRequest()

        // When
        let response = Response(request: request,
                                result: dataResponse,
                                metrics: metrics)

        // Then
        XCTAssertEqual(response.metrics.startDate, startDate)
        XCTAssertEqual(response.metrics.duration, duration)
        XCTAssertEqual(response.result.data, dataResponse.data)
        XCTAssertEqual(response.result.urlResponse.url, URL(string: "https://example.com"))
        XCTAssertEqual(response.request.method, HTTPMethod.get)
    }

    // MARK: - DataResponse, DownloadResponse, UploadResponse Tests

    func testDataResponseTuple() {
        // Given
        let data = Data("TestData".utf8)
        let urlResponse = URLResponse(url: URL(string: "https://example.com")!,
                                      mimeType: nil,
                                      expectedContentLength: 0,
                                      textEncodingName: nil)

        // When
        let dataResponse: DataResponse = (data: data, urlResponse: urlResponse)

        // Then
        XCTAssertEqual(dataResponse.data, data)
        XCTAssertEqual(dataResponse.urlResponse.url?.absoluteString, "https://example.com")
    }

    func testDownloadResponseTuple() {
        // Given
        let fileURL = URL(fileURLWithPath: "/tmp/testfile.txt")
        let urlResponse = URLResponse(url: fileURL,
                                      mimeType: nil,
                                      expectedContentLength: 0,
                                      textEncodingName: nil)

        // When
        let downloadResponse: DownloadResponse = (url: fileURL, urlResponse: urlResponse)

        // Then
        XCTAssertEqual(downloadResponse.url, fileURL)
        XCTAssertEqual(downloadResponse.urlResponse.url?.path, "/tmp/testfile.txt")
    }

    func testUploadResponseTypealias() {
        // Given
        let data = Data("UploadData".utf8)
        let urlResponse = URLResponse(url: URL(string: "https://upload.example.com")!,
                                      mimeType: nil,
                                      expectedContentLength: 0,
                                      textEncodingName: nil)

        // When
        let uploadResponse: UploadResponse = (data: data, urlResponse: urlResponse)

        // Then
        XCTAssertEqual(uploadResponse.data, data)
        XCTAssertEqual(uploadResponse.urlResponse.url?.absoluteString, "https://upload.example.com")
    }
}
