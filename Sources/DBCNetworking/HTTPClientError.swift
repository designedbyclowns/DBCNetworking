import Foundation

public enum HTTPClientError {
    case invalidResponse(response: HTTPURLResponse)

    public var statusCode: Int {
        switch self {
        case .invalidResponse(let response):
            return response.statusCode
        }
    }
    
    public var url: URL? {
        switch self {
        case .invalidResponse(let response):
            return response.url
        }
    }
}

// MARK: - LocalizedError

extension HTTPClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let response):
            return String(describing: response)
        }
    }
}

// MARK: - CustomNSError

extension HTTPClientError: CustomNSError {
    /// Default domain of the error.
    public static var errorDomain: String { "HTTPError" }
    /// The error code within the given domain.
    public var errorCode: Int { statusCode }
    /// The default user-info dictionary.
    public var errorUserInfo: [String : Any] {
        var userInfo = [String : Any]()
        userInfo[NSURLErrorFailingURLErrorKey] = url
        userInfo[NSUnderlyingErrorKey] = nil
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        return userInfo
    }
}
