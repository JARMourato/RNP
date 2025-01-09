// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

// MARK: - Requestable

/// A protocol that represents an entity capable of generating a `URLRequest`.
/// Includes HTTP headers, method, parameters, and the chosen encoding strategy.
public protocol Requestable {
    /// A collection of HTTP headers to include in the request.
    var headers: Headers { get set }

    /// The HTTP method (e.g., GET, POST), represented by a typed `HTTPMethod`.
    var method: HTTPMethod { get }

    /// A dictionary of parameters to be encoded and sent in the request body.
    var parameters: Parameters { get set }

    /// The parameter encoding strategy (e.g., JSON) to use when constructing the `URLRequest`.
    var parameterEncoding: ParameterEncoding { get }

    /// Builds and returns a `URLRequest` from the current properties.
    ///
    /// - Throws: An error if the request could not be built.
    /// - Returns: A fully configured `URLRequest` based on the current properties.
    func buildURLRequest() throws -> URLRequest
}

public extension Requestable {
    /// The default parameter encoding strategy. Override if you need a different encoding.
    var parameterEncoding: ParameterEncoding { .json }

    /// A convenience property indicating whether the request is a multipart/form-data request,
    /// based on the `Content-Type` header.
    var isMultipartRequest: Bool {
        headers.contains { header in
            header.key.lowercased() == "content-type"
                && header.value.lowercased().contains("multipart/form-data")
        }
    }

    /// A convenience property exposing the raw string value of the HTTP method.
    var rawMethod: String { method.rawValue }
}

/// Extends `URLRequest` to conform to `Requestable`, allowing you to treat
/// a Foundation `URLRequest` as if it were your own custom request type.
extension URLRequest: Requestable {
    /// A set of `HTTPHeader` objects, derived from and applied to
    /// the `allHTTPHeaderFields` of this `URLRequest`.
    public var headers: Headers {
        get {
            guard let allHTTPHeaderFields else { return [] }
            return Set(allHTTPHeaderFields.map(HTTPHeader.init))
        }
        set {
            var newHeaders: [String: String] = [:]
            newValue.forEach { newHeaders[$0.key] = $0.value }
            allHTTPHeaderFields = newHeaders
        }
    }

    /// Retrieves or sets the HTTP method using a typed `HTTPMethod`.
    /// Defaults to `"GET"` if `httpMethod` is `nil`.
    public var method: HTTPMethod {
        guard let httpMethod else { return .get }
        return HTTPMethod(rawValue: httpMethod)
    }

    /// Retrieves or sets the request parameters by converting `httpBody`
    /// to or from JSON. For other encodings, override as needed.
    public var parameters: Parameters {
        get {
            guard let body = httpBody else { return [:] }
            return (try? JSONSerialization.jsonObject(with: body) as? Parameters) ?? [:]
        }
        set {
            httpBody = try? JSONSerialization.data(withJSONObject: newValue)
        }
    }

    /// Returns this instance of `URLRequest` directly, since it is already
    /// configured. In more complex use cases, you may wish to apply
    /// different encoding strategies or validations here.
    public func buildURLRequest() throws -> URLRequest { self }
}

// MARK: - Mutable Request

/// A protocol that extends `Requestable` with a mutable base URL, enabling
/// dynamic modifications to the request's base URL.
public protocol MutableRequestable: Requestable {
    /// The base URL string that can be modified at runtime.
    var baseURLString: String? { get set }
}

// MARK: - Requestable Loader

/// A protocol for loading data from a given `Requestable` source.
public protocol RequestLoader {
    /// Asynchronously performs a request for the given `Requestable`,
    /// returning the raw `DataResponse`.
    ///
    /// - Parameter r: The `Requestable` containing request configuration.
    /// - Throws: Any error that occurs during the load operation.
    /// - Returns: A tuple containing the response data and the `URLResponse`.
    func data(for r: Requestable) async throws -> DataResponse
}

public extension RequestLoader {
    /// Asynchronously performs a request for the given `Requestable`, measures
    /// the request duration, and wraps the result in a `Response` with metrics.
    ///
    /// - Parameter r: The `Requestable` to perform the request for.
    /// - Throws: Any error thrown by `data(for:)`.
    /// - Returns: A `Response` instance containing the original request, response data, and metrics.
    func response<R: Requestable>(for r: R) async throws -> Response<R> {
        let startDate = Date()
        let result = try await data(for: r)
        let duration = startDate.distance(to: Date())
        let metrics = Metrics(startDate: startDate, duration: duration)
        return Response(request: r, result: result, metrics: metrics)
    }
}

// MARK: - URLRequest building protocols

/// A marker protocol for types that modify requests or responses.
public protocol RequestModifier {}

/// A protocol for building or mutating a `MutableRequestable`. This allows
/// custom transformations on the request before it's executed.
public protocol RequestBuilder: RequestModifier {
    /// Mutates the given `MutableRequestable` and returns a modified instance.
    ///
    /// - Parameter request: The `MutableRequestable` to be modified.
    /// - Returns: A potentially modified `MutableRequestable`.
    func mutate(_ request: MutableRequestable) -> MutableRequestable
}

// MARK: - Response Modifier

/// A protocol for modifying responses after they are created.
public protocol ResponseModifier: RequestModifier {
    /// Mutates the given `Response` and returns a modified instance.
    ///
    /// - Parameter response: The response to be modified.
    /// - Returns: A potentially modified `Response`.
    func mutate<R: Requestable>(_ response: Response<R>) -> Response<R>
}
