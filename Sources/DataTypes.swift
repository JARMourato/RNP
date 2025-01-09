// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Response Types

/**
 A structure that holds basic timing metrics for a given request operation.

 - Parameters:
    - startDate: The date and time when the operation started.
    - duration: The total duration of the operation, in seconds.
 */
public struct Metrics {
    /// The date and time when the operation started.
    public let startDate: Date

    /// The total duration of the operation, in seconds.
    public let duration: TimeInterval

    /**
     Initializes a new `Metrics` instance.

     - Parameters:
       - startDate: The date and time when the operation started.
       - duration: The total duration of the operation, in seconds.
     */
    public init(startDate: Date, duration: TimeInterval) {
        self.startDate = startDate
        self.duration = duration
    }
}

/**
 A generic response wrapper containing:
 - The request metrics.
 - The result, which is the raw data and URL response.
 - The original request type conforming to `Requestable`.

 This allows you to keep metadata about the request alongside the actual response data.
 */
public struct Response<Request: Requestable> {
    /// Performance metrics for this particular request.
    public let metrics: Metrics

    /// The tuple containing the response data and the underlying `URLResponse`.
    public let result: DataResponse

    /// The original request object, conforming to `Requestable`.
    public let request: Request

    /**
     Initializes a new `Response` instance.

     - Parameters:
       - request: The original request that was executed.
       - result: A tuple of response data and `URLResponse`.
       - metrics: Performance metrics for this request.
     */
    public init(request: Request, result: DataResponse, metrics: Metrics) {
        self.metrics = metrics
        self.request = request
        self.result = result
    }
}

/// A type alias representing a standard data response, containing the raw data and the `URLResponse`.
public typealias DataResponse = (data: Data, urlResponse: URLResponse)

/// A type alias representing a download response, containing a file `URL` and the `URLResponse`.
public typealias DownloadResponse = (url: URL, urlResponse: URLResponse)

/// A type alias for an upload response, which in this case is the same as a standard `DataResponse`.
public typealias UploadResponse = DataResponse

// MARK: - Request Types

/// A type alias for a closure that encodes request bodies into `Data`. It can throw if encoding fails.
public typealias BodyEncoder = () throws -> Data

/// A type alias representing a file parameter in multipart form data, consisting of a parameter name and a `File`.
public typealias FileParameter = (String, File)

/// A type alias for an array of file parameters, typically used in multipart form requests.
public typealias Files = [FileParameter]

/// A type alias for a set of HTTP headers, where each header is represented by `HTTPHeader`.
public typealias Headers = Set<HTTPHeader>

/// A type alias for a closure that encodes given parameters into `Data`. It can throw if encoding fails.
public typealias ParameterEncoder = (Parameters) throws -> Data

/// A type alias for request parameters, represented as a dictionary of `String: Any`.
public typealias Parameters = [String: Any]

/**
 A structure representing a file to be uploaded, including optional metadata such as filename and MIME type.

 - Parameters:
    - data: The raw file data.
    - fileData: An optional dictionary of additional file metadata.
    - filename: The name of the file being uploaded.
    - mimetype: The MIME type of the file (e.g., `image/png`), if available.
 */
public struct File {
    /// The raw file data.
    public let data: Data

    /// An optional dictionary of additional file metadata (e.g., form fields).
    public let fileData: Parameters?

    /// The name of the file being uploaded.
    public let filename: String

    /// The MIME type of the file (e.g., `image/png`), if available.
    public let mimetype: String?

    /**
     Initializes a new `File`.

     - Parameters:
       - data: The raw file data.
       - fileData: An optional dictionary of additional file metadata.
       - filename: The name of the file being uploaded.
       - mimetype: The MIME type of the file, if available.
     */
    public init(data: Data, fileData: Parameters?, filename: String, mimetype: String?) {
        self.data = data
        self.fileData = fileData
        self.filename = filename
        self.mimetype = mimetype
    }
}
