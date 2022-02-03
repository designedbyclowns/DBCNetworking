import Foundation

/// RFC 2616 - 5.3 Request Header Fields
///
/// The request-header fields allow the client to pass additional
/// information about the request, and about the client itself, to the
/// server. These fields act as request modifiers, with semantics
/// equivalent to the parameters on a programming language method
/// invocation.
///
/// - NOTE: Extend HeaderField as needed to provide type safe, custom headers.
public struct HeaderField: Hashable, CustomStringConvertible {
    let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
}

// MARK: - Request Header Fields

public extension HeaderField {
    static let aIm                 = Self("A-IM")
    static let accept              = Self("Accept")
    static let acceptCharset       = Self("Accept-Charset")
    static let acceptDatetime      = Self("Accept-Datetime")
    static let acceptEncoding      = Self("Accept-Encoding")
    static let acceptLanguage      = Self("Accept-Language")
    static let authorization       = Self("Authorization")
    static let cacheControl        = Self("Cache-Control")
    static let connection          = Self("Connection")
    static let contentEncoding     = Self("Content-Encoding")
    static let contentLength       = Self("Content-Length")
    static let contentMD5          = Self("Content-MD5")
    static let contentType         = Self("Content-Type")
    static let cookie              = Self("Cookie")
    static let date                = Self("Date")
    static let expect              = Self("Expect")
    static let forwarded           = Self("Forwarded")
    static let from                = Self("From")
    static let host                = Self("Host")
    static let http2Settings       = Self("HTTP2-Settings")
    static let ifMatch             = Self("If-Match")
    static let ifModifiedSince     = Self("If-Modified-Since")
    static let ifNoneMatch         = Self("If-None-Match")
    static let ifRange             = Self("If-Range")
    static let ifUnmodifiedSince   = Self("If-Unmodified-Since")
    static let maxForwards         = Self("Max-Forwards")
    static let origin              = Self("Origin")
    static let pragma              = Self("Pragma")
    static let proxyAuthorization  = Self("Proxy-Authorization")
    static let range               = Self("Range")
    static let referer             = Self("Referer")
    static let te                  = Self("TE")
    static let trailer             = Self("Trailer")
    static let transferEncoding    = Self("Transfer-Encoding")
    static let userAgent           = Self("User-Agent")
    static let upgrade             = Self("Upgrade")
    static let via                 = Self("Via")
    static let warning             = Self("Warning")
}

// MARK: - Response Headers

/// RFC 2616 - 6.2 Response Header Fields
///
///  The response-header fields allow the server to pass additional
///  information about the response which cannot be placed in the Status-
///  Line. These header fields give information about the server and about
///  further access to the resource identified by the Request-URI.
public extension HeaderField {
    static let acceptRanges      = Self("Accept-Ranges")
    static let age               = Self("Age")
    static let etag              = Self("ETag")
    static let location          = Self("Location")
    static let proxyAuthenticate = Self("Proxy-Authenticate")
    static let retryAfter        = Self("Retry-After")
    static let server            = Self("Server")
    static let vary              = Self("Vary")
    static let wwwAuthenticate   = Self("WWW-Authenticate")
}
