import Foundation

public final class MockHTTPClientProtocol: URLProtocol {
    
    public typealias MockRequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data)
    
    /// A function that mocks the response and data for a request.
    static public var requestHandler: MockRequestHandler?
    /// An optional delay used to simulate response time.
    static public var delay: DispatchTimeInterval?
    
    /// Determines whether the protocol subclass can handle the specified request.
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    /// Returns a canonical version of the specified request.
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// Starts protocol-specific loading of the request.
    public override func startLoading() {
        guard let handler = Self.requestHandler else { return }
        

        guard let delay = Self.delay else {
            perform(request, handler: handler)
            return
        }
        
        self.responseWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            self.perform(self.request, handler: Self.requestHandler!)
        })
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
            .asyncAfter(deadline: .now() + delay, execute: responseWorkItem!)
    }
    
    /// Stops protocol-specific loading of the request.
    public override func stopLoading() {
        // Called when the request is canceled or completed.
    }
    
    // MARK: - Private
    
    private var responseWorkItem: DispatchWorkItem?
    
    private func perform(_ request: URLRequest, handler: MockRequestHandler) {
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowedInMemoryOnly)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch  {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}

public extension HTTPURLResponse {
    /// Creates a mock response, with some sensible defaults.
    static func mockResponse(url: URL, status: HTTPStatus,
                             httpVersion: String = "2.0",
                             headerFields: [HeaderField: String] = [:]) -> HTTPURLResponse? {
        return HTTPURLResponse(url: url,
                               statusCode: status.code,
                               httpVersion: httpVersion,
                               headerFields: Dictionary(uniqueKeysWithValues: headerFields.map { ($0.rawValue, $1) })
        )
    }
}
