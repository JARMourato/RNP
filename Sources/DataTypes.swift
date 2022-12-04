// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Response Types

public struct Metrics {
    public let startDate: Date
    public let duration: TimeInterval

    public init(startDate: Date, duration: TimeInterval) {
        self.startDate = startDate
        self.duration = duration
    }
}

public struct Response<Request: Requestable> {
    public let metrics: Metrics
    public let result: DataResponse
    public let request: Request

    public init(request: Request, result: DataResponse, metrics: Metrics) {
        self.metrics = metrics
        self.request = request
        self.result = result
    }
}

public typealias DataResponse = (data: Data, urlResponse: URLResponse)
public typealias DownloadResponse = (url: URL, urlResponse: URLResponse)
public typealias UploadResponse = DataResponse

// MARK: - Request Types

public typealias BodyEncoder = () throws -> Data
public typealias FileParameter = (String, File)
public typealias Files = [FileParameter]
public typealias Headers = Set<HTTPHeader>
public typealias ParameterEncoder = (Parameters) throws -> Data
public typealias Parameters = [String: Any]

public struct File {
    public let data: Data
    public let fileData: Parameters?
    public let filename: String
    public let mimetype: String?

    public init(data: Data, fileData: Parameters?, filename: String, mimetype: String?) {
        self.data = data
        self.fileData = fileData
        self.filename = filename
        self.mimetype = mimetype
    }
}
