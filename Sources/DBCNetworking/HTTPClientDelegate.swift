import Foundation

/// A delegate that provides a variety of hooks to interact with the HTTP request/response cycle.
public protocol HTTPClientDelegate {
    /// Informs the delegate that the client is about to send the request.
    ///
    /// Provides an opportunity for the delegate to modify the request before it is sent.
    func client(_ client: HTTPClient, willSendRequest request: inout URLRequest)

    /// Asks the delegate if the client should retry the request after receiving an error.
    ///
    /// This could be used to re-authenticate short lived auth tokens etc.
    func shouldClientRetry(_ client: HTTPClient, withError error: Error) -> Bool

    /// Tells the delegate that the client received an invalid response.
    ///
    /// The included `response` and `data` allow the delegate to interpret the error.
    func client(_ client: HTTPClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error
}

public extension HTTPClientDelegate {
    func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) {}
    
    func shouldClientRetry(_ client: HTTPClient, withError error: Error) -> Bool { false }
    
    func client(_ client: HTTPClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error {
        HTTPClientError.invalidResponse(response: response)
    }
}
