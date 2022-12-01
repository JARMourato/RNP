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
