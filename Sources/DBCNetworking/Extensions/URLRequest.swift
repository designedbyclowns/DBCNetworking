import Foundation

public extension URLRequest {
    /// Retrieves a header value.
    /// - Parameter field: The ``HeaderField`` to use for the lookup.
    /// - Returns: The value which corresponds to the given header.
    func value(forHTTPHeaderField field: HeaderField) -> String? {
        return value(forHTTPHeaderField: field.rawValue)
    }

    /// Sets a value for the header field.
    ///
    /// If a value was previously set for the given header
    /// field, that value is replaced with the given value. Note that, in
    /// keeping with the HTTP RFC, HTTP header field names are
    /// case-insensitive.
    ///
    /// Certain header fields are reserved (see Reserved HTTP Headers).
    /// Do not use this method to change such headers.
    ///
    /// - Parameters:
    ///   - value: The new value for the header field. Any existing value for the field is replaced by the new value.
    ///   - field: The ``HeaderField`` to set.
    mutating func setValue(_ value: String?, forHTTPHeaderField field: HeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }

    /// Adds a value to the header field.
    ///
    /// This method provides a way to add values to header
    /// fields incrementally. If a value was previously set for the given
    /// header field, the given value is appended to the previously-existing
    /// value. The appropriate field delimiter, a comma in the case of HTTP,
    /// is added by the implementation, and should not be added to the given
    /// value by the caller.
    ///
    /// Certain header fields are reserved (see Reserved HTTP Headers).
    /// Do not use this method to change such headers.
    ///
    /// - Parameters:
    ///   - value: The value for the header field.
    ///   - field: The ``HeaderField``.
    mutating func addValue(_ value: String, forHTTPHeaderField field: HeaderField) {
        addValue(value, forHTTPHeaderField: field.description)
    }

    /// Sets the values for the provided header fields.
    ///
    /// If a value was previously set for the given header
    /// field, that value is replaced with the given value. Note that, in
    /// keeping with the HTTP RFC, HTTP header field names are
    /// case-insensitive.
    ///
    /// Certain header fields are reserved (see Reserved HTTP Headers).
    /// Do not use this method to change such headers.
    ///
    /// - Parameter headers: A dictionary of ``HeaderField`` keys and their values.
    mutating func setHeaders(_ headers: [HeaderField: String]) {
        for (field, value) in headers {
            setValue(value, forHTTPHeaderField: field)
        }
    }

    /// Adds a value to the provided header fields.
    ///
    /// This method provides a way to add values to header
    /// fields incrementally. If a value was previously set for the given
    /// header field, the given value is appended to the previously-existing
    /// value. The appropriate field delimiter, a comma in the case of HTTP,
    /// is added by the implementation, and should not be added to the given
    /// value by the caller.
    ///
    /// Certain header fields are reserved (see Reserved HTTP Headers).
    /// Do not use this method to change such headers.
    ///
    /// - Parameter headers: A dictionary of ``HeaderField`` keys and their values.
    mutating func addHeaders(_ headers: [HeaderField: String]) {
        for (field, value) in headers {
            addValue(value, forHTTPHeaderField: field)
        }
    }
}

public extension URLRequest {
    /// True if the `Content-Type` header says so.
    var isJSON: Bool {
        return contentType?.lowercased().starts(with: "application/json") ?? false
    }

    /// Returns the value of the `Content-Type` header
    var contentType: String? {
        value(forHTTPHeaderField: HeaderField.contentType)
    }
    
    /// Sets the `Authorization` header to a bearer token using the provided string.
    /// - Parameter token: The bearer token.
    ///
    /// If the string in nil or empty, the `Authorization` header wil be removed from the request.
    mutating func setBearerToken(_ token: String?) {
        let bearerToken = (token ?? "").isEmpty ? nil : "Bearer \(token!)"
        setValue(bearerToken, forHTTPHeaderField: .authorization)
    }
}

extension URLRequest {
    public var logDescription: String {
        var components: [String] = []

        var summary = "<\(type(of: self))>"
        if let url = url {
            let method = httpMethod ?? "METHOD UNKNOWN"
            summary.append(" \(method) \(url.absoluteString)")
        }
        components.append(summary)

        var props: [String: Any] = [:]
        props["cachePolicy"] = String(describing: cachePolicy)
        props["timeoutInterval"] = timeoutInterval
        props["body"] = httpBody?.logDescription

        if var headers = allHTTPHeaderFields {
            if let _ = headers[HeaderField.authorization.rawValue] {
                headers[HeaderField.authorization.rawValue] = "<private>"
            }
            props["headers"] = headers
        }

        components.append(String(describing: props))

        return components.joined(separator: ", ")
    }
}

extension URLRequest.CachePolicy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .useProtocolCachePolicy:
            return "useProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData:
            return "reloadIgnoringLocalCacheData"
        case .returnCacheDataElseLoad:
            return "returnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            return "returnCacheDataDontLoad"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "reloadIgnoringLocalAndRemoteCacheData"
        case .reloadRevalidatingCacheData:
            return "reloadRevalidatingCacheData"
        @unknown default:
            assertionFailure()
            return "UNKNOWN"
        }
    }
}
