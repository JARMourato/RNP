// Copyright © 2022 João Mourato. All rights reserved.

import Foundation

/// Represent the encoding of parameters in an `URLRequest`.
public struct ParameterEncoding: Hashable {
    public static let json = ParameterEncoding(rawValue: "application/json")
    public static let url = ParameterEncoding(rawValue: "application/x-www-form-urlencoded")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - HTTP Types

/// Type representing HTTP methods.
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public struct HTTPMethod: Hashable {
    public static let connect = HTTPMethod(rawValue: "CONNECT")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let get = HTTPMethod(rawValue: "GET")
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    public static let patch = HTTPMethod(rawValue: "PATCH")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let trace = HTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A wrapper type for a set of common HTTP headers.
public struct HTTPHeader: Hashable {
    public static func accept(_ value: String) -> HTTPHeader { HTTPHeader(key: "Accept", value: value) }
    public static func acceptEncoding(_ value: String) -> HTTPHeader { HTTPHeader(key: "Accept-Encoding", value: value) }
    public static func acceptLanguage(_ value: String) -> HTTPHeader { HTTPHeader(key: "Accept-Language", value: value) }
    public static func authorization(_ value: String) -> HTTPHeader { HTTPHeader(key: "Authorization", value: value) }
    public static func authorizationBearer(_ token: String) -> HTTPHeader { HTTPHeader(key: "Authorization", value: "Bearer \(token)") }
    public static func cacheControl(_ value: String) -> HTTPHeader { HTTPHeader(key: "Cache-Control", value: value) }
    public static func contentLength(_ value: Int) -> HTTPHeader { HTTPHeader(key: "Content-Length", value: String(value)) }
    public static func contentType(_ value: String) -> HTTPHeader { HTTPHeader(key: "Content-Type", value: value) }
    public static func cookie(_ value: String) -> HTTPHeader { HTTPHeader(key: "Cookie", value: value) }
    public static func host(_ value: String) -> HTTPHeader { HTTPHeader(key: "Host", value: value) }
    public static func ifMatch(_ etag: String) -> HTTPHeader { HTTPHeader(key: "If-Match", value: etag) }
    public static func ifModifiedSince(_ date: String) -> HTTPHeader { HTTPHeader(key: "If-Modified-Since", value: date) }
    public static func ifNoneMatch(_ etag: String) -> HTTPHeader { HTTPHeader(key: "If-None-Match", value: etag) }
    public static func ifUnmodifiedSince(_ date: String) -> HTTPHeader { HTTPHeader(key: "If-Unmodified-Since", value: date) }
    public static func origin(_ value: String) -> HTTPHeader { HTTPHeader(key: "Origin", value: value) }
    public static func referer(_ value: String) -> HTTPHeader { HTTPHeader(key: "Referer", value: value) }
    public static func userAgent(_ value: String) -> HTTPHeader { HTTPHeader(key: "User-Agent", value: value) }

    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
