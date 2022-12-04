// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Requestable

public protocol Requestable {
    var headers: Headers { get set }
    var method: String { get }
    var parameters: Parameters { get set }

    func buildURLRequest() throws -> URLRequest
}

extension Requestable {
    public var isMultipartRequest: Bool { headers.contains { $0.key.contains("multipart") } }
}

extension URLRequest: Requestable {
    public var headers: Headers {
        get {
            guard let allHTTPHeaderFields else { return [] }
            return Set(allHTTPHeaderFields.map(HTTPHeader.init))
        }
        set {
            var newHeaders: [String:String] = [:]
            newValue.forEach { newHeaders[$0.key] = $0.value }
            allHTTPHeaderFields = newHeaders
        }
    }

    public var parameters: Parameters {
        get {
            guard let body = httpBody else { return [:] }
            return (try? JSONSerialization.jsonObject(with: body) as? Parameters) ?? [:]
        }
        set {
            httpBody = try? JSONSerialization.data(withJSONObject: newValue)
        }
    }

    public var isMultipartRequest: Bool { allHTTPHeaderFields?.keys.contains(where: { $0.contains("multipart/form-data") }) ?? false }
    public var method: String { httpMethod ?? "N/A" }
    public func buildURLRequest() throws -> URLRequest { self }
}

// MARK: - Mutable Request

public protocol MutableRequestable: Requestable {
    var baseURLString: String? { get set }
}

// MARK: - Requestable Loader

public protocol RequestLoader {
    func data(for r: Requestable) async throws -> DataResponse
}

public extension RequestLoader {
    func response<R: Requestable>(for r: R) async throws -> Response<R> {
        let startDate = Date()
        let result = try await data(for: r)
        let duration = startDate.distance(to: Date())
        let metrics = Metrics(startDate: startDate, duration: duration)
        return Response(request: r, result: result, metrics: metrics)
    }
}

// MARK: - URLRequest building protocols

public protocol RequestModifier {}

public protocol RequestBuilder: RequestModifier {
    func mutate(_ request: MutableRequestable) -> MutableRequestable
}

// MARK: - Response Modifier

public protocol ResponseModifier: RequestModifier {
    func mutate<R: Requestable>(_ response: Response<R>) -> Response<R>
}
