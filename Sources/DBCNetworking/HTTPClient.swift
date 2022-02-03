import Foundation

/// Provides a very simple API to create custom clients for any service.
public actor HTTPClient {

    /// The configuration for an ``HTTPClient``.
    public struct Configuration {
        /// The host to use.
        ///
        /// If a valid url string is provided, the host will be extracted from the URL.
        public var host: String
        /// The port.
        ///
        /// If not provided the port will be determined by the scheme.
        public var port: Int?
        /// If `true`, uses `http` instead of `https`.
        public var isInsecure = false
        /// An (optional) custom URLSessionConfiguration.
        public var sessionConfiguration: URLSessionConfiguration = .default
        /// By default, uses decoder with `.iso8601` date decoding strategy.
        public var decoder: JSONDecoder?
        /// By default, uses encoder with `.iso8601` date encoding strategy.
        public var encoder: JSONEncoder?
        /// The (optional) client delegate.
        public var delegate: HTTPClientDelegate?
        /// The (optional) URLSession delegate that allows you to monitor the underlying URLSession.
        public var sessionDelegate: URLSessionDelegate?

        /// If an error occurs, load cached data if it exists. Defaults to false.
        ///
        /// The intent here is to try and load any previously successful response, regardless of age. If there
        /// is no cached response, or it cannot be loaded for any reason, the original error will be thrown.
        ///
        /// For some types of requests, this can be useful when offline, or otherwise unable to load the request.
        ///
        /// There is no `URLRequest.CachePolicy` that provides this behavior, which is why this property is needed.
        public var loadCachedResponseOnError: Bool = false
    
        public init(host: String,
                    sessionConfiguration: URLSessionConfiguration = .default,
                    delegate: HTTPClientDelegate? = nil) {
            // If the host string includes a scheme, disregard it
            self.host = URL(string: host)?.host ?? host
            self.sessionConfiguration = sessionConfiguration
            self.delegate = delegate
        }
    }

    /// Initializes the client with the given parameters.
    ///
    /// - parameter host: A host to be used for requests with relative paths.
    /// - parameter configure: Updates the client configuration.
    public convenience init(host: String, _ configure: (inout HTTPClient.Configuration) -> Void = { _ in }) {
        var configuration = Configuration(host: host)
        configure(&configuration)
        self.init(configuration: configuration)
    }

    /// Initializes the client with the given configuration.
    public init(configuration: Configuration) {
        self.config = configuration
        let queue = OperationQueue(maxConcurrentOperationCount: 1)
        let delegate = URLSessionProxyDelegate.make(loader: loader, delegate: configuration.sessionDelegate)
        self.session = URLSession(configuration: configuration.sessionConfiguration,
                                  delegate: delegate, delegateQueue: queue)
        self.delegate = configuration.delegate ?? DefaultClientDelegate()
        self.serializer = Serializer(decoder: configuration.decoder, encoder: configuration.encoder)
    }

    /// Sends the given request and returns a response with a decoded response value.
    public func send<T: Decodable>(_ request: HTTPRequest<T?>) async throws -> HTTPResponse<T?> {
        try await send(request) { data in
            if data.isEmpty {
                return nil
            } else {
                return try await self.decode(data)
            }
        }
    }
    
    /// Sends the given request and returns a response with a decoded response value.
    public func send<T: Decodable>(_ request: HTTPRequest<T>) async throws -> HTTPResponse<T> {
        try await send(request, decode)
    }
    
    /// Sends the given request.
    @discardableResult
    public func send(_ request: HTTPRequest<Void>) async throws -> HTTPResponse<Void> {
        try await send(request) { _ in () }
    }
    
    /// Returns response data for the given request.
    public func data<T>(for request: HTTPRequest<T>) async throws -> HTTPResponse<Data> {
        let request = try await makeRequest(for: request)
        return try await send(request)
    }
    
    // MARK: - Internal
    
    internal var urlCache: URLCache? { config.sessionConfiguration.urlCache }
    
    // MARK: - Private
    
    private let config: Configuration
    private let session: URLSession
    private let serializer: Serializer
    private let delegate: HTTPClientDelegate
    private let loader = DataLoader()
    
    private func send<T>(_ request: HTTPRequest<T>,
                         _ decode: @escaping (Data) async throws -> T) async throws -> HTTPResponse<T> {
        let response = try await data(for: request)
        let value = try await decode(response.value)
        return response.map { _ in value } // Keep metadata
    }

    private func send(_ request: URLRequest) async throws -> HTTPResponse<Data> {
        do {
            return try await load(request)
        } catch {
            guard delegate.shouldClientRetry(self, withError: error) else { throw error }
            return try await load(request)
        }
    }

    private func load(_ request: URLRequest) async throws -> HTTPResponse<Data> {
        var request = request
        delegate.client(self, willSendRequest: &request)
        
        do {
            let (data, response, metrics) = try await loader.data(for: request, session: session)
            try validate(response: response, data: data)
            return HTTPResponse(value: data, data: data, request: request, response: response, metrics: metrics)
            
        } catch {
            // Attempt to load a cached response, if configured to do so.
            guard
                config.loadCachedResponseOnError,
                let cachedResponse = self.urlCache?.cachedResponse(for: request)
            else {
                // throw original error
                throw error
            }
            
            return HTTPResponse(value: cachedResponse.data,
                                data: cachedResponse.data,
                                request: request,
                                response: cachedResponse.response,
                                metrics: nil)
        }
        
    }
    
    private func decode<T: Decodable>(_ data: Data) async throws -> T {
        if T.self == Data.self {
            return data as! T
            //swiflint:disable:previous force_cast
        } else if T.self == String.self {
            guard let string = String(data: data, encoding: .utf8) else { throw URLError(.badServerResponse) }
            return string as! T
            //swiflint:disable:previous force_cast
        } else {
            return try await self.serializer.decode(data)
        }
    }

    internal func makeRequest<T>(for request: HTTPRequest<T>) async throws -> URLRequest {
        let url = try makeURL(path: request.path, query: request.query)
        return try await makeRequest(url: url, method: request.method, body: request.body, headers: request.headers)
    }

    private func makeURL(path: String, query: [(String, String?)]?) throws -> URL {
        guard
            let url = URL(string: path),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw URLError(.badURL)
        }
        
        if path.starts(with: "/") {
            components.scheme = config.isInsecure ? "http" : "https"
            components.host = config.host
            if let port = config.port {
                components.port = port
            }
        }
        
        if let query = query {
            components.queryItems = query.map(URLQueryItem.init)
        }
        
        guard let url = components.url else { throw URLError(.badURL) }
        
        return url
    }

    private func makeRequest(url: URL, method: RequestMethod,
                             body: AnyEncodable?,
                             headers: [HeaderField: String]?) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.setHeaders(headers ?? [:])
        request.httpMethod = method.rawValue
        
        let mediaType = MediaType.applicationJsonCharsetUTF8
        
        if let body = body {
            request.httpBody = try await serializer.encode(body)
            request.setValue(String(describing: mediaType), forHTTPHeaderField: .contentType)
        }
        
        request.setValue(String(describing: mediaType), forHTTPHeaderField: .accept)
        return request
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        if !(200..<300).contains(httpResponse.statusCode) {
            throw delegate.client(self, didReceiveInvalidResponse: httpResponse, data: data)
        }
    }
}

private struct DefaultClientDelegate: HTTPClientDelegate {}
