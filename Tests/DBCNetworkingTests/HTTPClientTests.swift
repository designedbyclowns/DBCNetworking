import XCTest
@testable import DBCNetworking

final class HTTPClientTests: XCTestCase {
    
    // Chewbacca!
    static let testUrl = URL(string: "https://swapi.dev/api/people/13")!
    static let mockData = loadJson(named: "Chewbacca")
    
    var config: HTTPClient.Configuration!
    
    override func setUp() {
        super.setUp()
        
        let sessionConfig: URLSessionConfiguration = .ephemeral
        sessionConfig.protocolClasses = [MockHTTPClientProtocol.self]
        
        config = HTTPClient.Configuration(host: "swapi.dev", sessionConfiguration: sessionConfig, delegate: nil)
        config.decoder = SwapiClient.decoder
    }
    
    override func tearDown() {
        super.tearDown()
        MockHTTPClientProtocol.delay = nil
        MockHTTPClientProtocol.requestHandler = nil
        config = nil
    }
    
    func testResponse() async throws {
        MockHTTPClientProtocol.requestHandler = { request in
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .ok)!
            return (response, Self.mockData)
        }
        
        let client = HTTPClient(configuration: config)
                
        let req: HTTPRequest<SwapiPeople> = HTTPRequest.get(Self.testUrl.path)
        let response = try await client.send(req)
        
        XCTAssertEqual(response.value.name, "Chewbacca")
        XCTAssertEqual(response.data.count, 764)
        XCTAssertEqual(response.request.url, Self.testUrl)
        XCTAssertEqual(response.statusCode, 200)
        let metrics = try XCTUnwrap(response.metrics)
        let transaction = try XCTUnwrap(metrics.transactionMetrics.first)
        XCTAssertEqual(transaction.request.url, Self.testUrl)
    }
    
    func testCancel() async throws {
        MockHTTPClientProtocol.delay = DispatchTimeInterval.seconds(60)
        
        MockHTTPClientProtocol.requestHandler =  { request in
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .ok)!
            return (response, Self.mockData)
        }
        
        let client = HTTPClient(configuration: config)
        
        let task = Task {
            try await client.send(.get(Self.testUrl.path))
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
            task.cancel()
        }
        
        do {
            _ = try await task.value
            XCTFail("Expected to throw while awaiting, but succeeded")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .cancelled)
        }
    }
    
    func testDelegateWillSendRequest() async throws {
        struct TestDelegate: HTTPClientDelegate {
            func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) {
                XCTAssertEqual(request.url, HTTPClientTests.testUrl)
            }
        }
        
        MockHTTPClientProtocol.requestHandler =  { request in
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .ok)!
            return (response, Self.mockData)
        }
        
        let delegate = TestDelegate()
        config.delegate = delegate
        
        let client = HTTPClient(configuration: config)
        
        try await client.send(.get(Self.testUrl.path))
    }
    
    func testDelegateShouldClientRetry() async throws {
        class TestDelegate: HTTPClientDelegate {
            var wasCalled: Bool = false
            
            func shouldClientRetry(_ client: HTTPClient, withError error: Error) -> Bool {
                XCTAssertTrue(error is HTTPClientError)
                XCTAssertEqual(418, (error as? HTTPClientError)?.statusCode)
                XCTAssertEqual(HTTPClientTests.testUrl, (error as? HTTPClientError)?.url)
                
                wasCalled = true
                return true
            }
        }
        
        MockHTTPClientProtocol.requestHandler =  { request in
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .teapot)!
            return (response, Self.mockData)
        }
        
        let delegate = TestDelegate()
        config.delegate = delegate
        
        let client = HTTPClient(configuration: config)
                
        do {
            _ = try await client.send(.get(Self.testUrl.path))
            XCTFail("Expected to throw while awaiting, but succeeded")
        } catch {
            XCTAssertTrue(error is HTTPClientError)
            XCTAssertEqual(418, (error as? HTTPClientError)?.statusCode)
            XCTAssertTrue(delegate.wasCalled)
        }
    }
    
    func testDelegateDidReceiveInvalidResponse() async throws {
        
        struct TestDelegate: HTTPClientDelegate {
            func client(_ client: HTTPClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error {
                XCTAssertEqual(418, response.statusCode)
                XCTAssertEqual(HTTPClientTests.testUrl, response.url)
                return URLError(.badServerResponse)
            }
        }
        
        MockHTTPClientProtocol.requestHandler =  { request in
            let data = Data()
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .teapot)!
            return (response, data)
        }
        
        let delegate = TestDelegate()
        config.delegate = delegate
        
        let client = HTTPClient(configuration: config)
                
        do {
            try await client.send(.get(Self.testUrl.path))
            XCTFail("Expected to throw while awaiting, but succeeded")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual(URLError.Code.badServerResponse, (error as? URLError)?.code)
        }
    }
    
    func testLoadCachedResponseOnError() async throws {
                
        let mockData = Self.mockData
        let mockResponse = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .ok)!
        
        MockHTTPClientProtocol.requestHandler = { request in
            let data = Data()
            let response = HTTPURLResponse.mockResponse(url: Self.testUrl, status: .gatewayTimeout)!
            return (response, data)
        }
        
        let request: HTTPRequest<SwapiPeople> = HTTPRequest.get(Self.testUrl.path)
        
        // Disable loadCachedResponseOnError
        config.loadCachedResponseOnError = false
        
        var client = HTTPClient(configuration: config)
        
        // cache the successful response
        let cachedResponse = try await client.cacheResponse(response: mockResponse, data: mockData, forRequest: request)
        XCTAssertNotNil(cachedResponse)
        
        do {
            try await client.send(.get(Self.testUrl.path))
            XCTFail("Expected to throw while awaiting, but succeeded")
            
        } catch HTTPClientError.invalidResponse(let response) {
            XCTAssertEqual(HTTPStatus.gatewayTimeout, response.status)
            XCTAssertEqual(Self.testUrl, response.url)
            
        } catch {
            XCTFail("Unexpected Error: \(String(describing: error))")
        }
        
        // Enable loadCachedResponseOnError
        config.loadCachedResponseOnError = true
        
        client = HTTPClient(configuration: config)

        let response = try await client.send(request)
        
        XCTAssertEqual(response.value.name, "Chewbacca")
        XCTAssertEqual(response.data.count, 764)
        XCTAssertEqual(response.request.url, Self.testUrl)
        XCTAssertEqual(response.statusCode, 200)
    }
}

extension HTTPClient {
    @discardableResult
    internal func cacheResponse<T>(response: HTTPURLResponse, data: Data, forRequest request: HTTPRequest<T>) async throws -> CachedURLResponse? {
        
        guard let urlCache = self.urlCache else { return nil }
        
        let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowedInMemoryOnly)
        
        let req = try await makeRequest(for: request)

        urlCache.storeCachedResponse(cachedResponse, for: req)
        
        return cachedResponse
    }
}
