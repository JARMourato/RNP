// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Requestable

public protocol Requestable {
    func buildURLRequest() throws -> URLRequest
}

extension URLRequest: Requestable {
    public func buildURLRequest() throws -> URLRequest { self }
}

// MARK: - Mutable Request

public protocol MutableRequestable: Requestable {
    var baseURLString: String? { get set }
    var headers: Headers { get set }
    var parameters: Parameters { get set }
}

// MARK: - Requestable Loader

public protocol Loader {
    func data(for r: Requestable) async throws -> DataResponse
}

public extension Loader {
    func dataResponse<R: Requestable>(for r: R) async throws -> Response<R, DataResponse> {
        Response(request: r, result: try await data(for: r))
    }
}
