import Foundation

/// Models an HTTP request with a response type.
public struct HTTPRequest<Response> {
    public var method: RequestMethod
    public var path: String
    public var query: [(String, String?)]?
    var body: AnyEncodable?
    public var headers: [HeaderField: String]?
    public let id = UUID()
        
    // MARK: - GET
    
    /// Creates a GET request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func get(_ path: String,
                           query: [(String, String?)]? = nil,
                           headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .get, path: path, query: query, headers: headers)
    }
    
    // MARK: - POST
    
    /// Creates a POST request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func post(_ path:
                            String, query: [(String, String?)]? = nil,
                            headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .post, path: path, query: query, headers: headers)
    }
    
    /// Creates a POST request with a body of the specified Encodable type.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - body: An Encodable type.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func post<U: Encodable>(_ path: String,
                                          query: [(String, String?)]? = nil,
                                          body: U?,
                                          headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .post, path: path, query: query, body: body.map(AnyEncodable.init), headers: headers)
    }
    
    // MARK: - PUT
    
    /// Creates a PUT request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func put(_ path: String,
                           query: [(String, String?)]? = nil,
                           headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .put, path: path, query: query, headers: headers)
    }
    
    /// Creates a PUT request with a body of the specified Encodable type.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - body: An Encodable type.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func put<U: Encodable>(_ path: String,
                                         query: [(String, String?)]? = nil,
                                         body: U?,
                                         headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .put, path: path, query: query, body: body.map(AnyEncodable.init), headers: headers)
    }
    
    // MARK: - PATCH
    
    /// Creates a PATCH request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func patch(_ path: String,
                             query: [(String, String?)]? = nil,
                             headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .patch, path: path, query: query, headers: headers)
    }
    
    /// Creates a PATCH request with a body of the specified Encodable type.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - body: An Encodable type.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func patch<U: Encodable>(_ path: String,
                                           query: [(String, String?)]? = nil,
                                           body: U?,
                                           headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .patch, path: path, query: query, body: body.map(AnyEncodable.init), headers: headers)
    }
    
    // MARK: - DELETE
    
    /// Creates a DELETE request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func delete(_ path: String,
                              query: [(String, String?)]? = nil,
                              headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .delete, path: path, query: query, headers: headers)
    }
    
    /// Creates a DELETE request with a body of the specified Encodable type.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - body: An Encodable type.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func delete<U: Encodable>(_ path: String,
                                            query: [(String, String?)]? = nil,
                                            body: U?,
                                            headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .delete, path: path, query: query, body: body.map(AnyEncodable.init), headers: headers)
    }
    
    // MARK: - OPTIONS
    
    /// Creates a OPTIONS request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func options(_ path: String,
                               query: [(String, String?)]? = nil,
                               headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .options, path: path, query: query, headers: headers)
    }
    
    // MARK: - HEAD
    
    /// Creates a HEAD request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func head(_ path: String,
                            query: [(String, String?)]? = nil,
                            headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .head, path: path, query: query, headers: headers)
    }
    
    // MARK: - TRACE
    
    /// Creates a TRACE request.
    /// - Parameters:
    ///   - path: The resource path.
    ///   - query: Optional query parameters.
    ///   - headers: Optional HTTP headers.
    /// - Returns: An ``HTTPRequest``.
    public static func trace(_ path: String,
                             query: [(String, String?)]? = nil,
                             headers: [HeaderField: String]? = nil) -> HTTPRequest {
        HTTPRequest(method: .trace, path: path, query: query, headers: headers)
    }
}


