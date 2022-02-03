import Foundation

/// A response with a value and associated metadata.
public struct HTTPResponse<T> {
    public var value: T
    /// Original response data.
    public var data: Data
    /// Original request.
    public var request: URLRequest
    public var response: URLResponse
    public var metrics: URLSessionTaskMetrics?
    public var status: HTTPStatus? { (response as? HTTPURLResponse)?.status }
    public var statusCode: Int? { status?.code }
    
    public init(value: T, data: Data, request: URLRequest, response: URLResponse, metrics: URLSessionTaskMetrics? = nil) {
        self.value = value
        self.data = data
        self.request = request
        self.response = response
        self.metrics = metrics
    }
    
    func map<U>(_ closure: (T) -> U) -> HTTPResponse<U> {
        HTTPResponse<U>(value: closure(value), data: data, request: request, response: response, metrics: metrics)
    }
}
