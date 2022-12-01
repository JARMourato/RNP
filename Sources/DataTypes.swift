// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Response Types

public struct Response<Request: Requestable, Data> {
    let request: Request
    let result: Data

    public init(request: Request, result: Data) {
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
