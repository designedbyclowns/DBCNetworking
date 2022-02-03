import Foundation
import ArgumentParser
import DBCNetworking

struct Get: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "GETs a URL",
        discussion: "Performs an HTTP GET request to load the specified URL."
    )

    @OptionGroup var opts: HTTPTool.Options

    var isVerbose: Bool { opts.verbose }

    func runAsync() async throws {
        guard let url = opts.url, let host = url.host else {
            throw ValidationError("Invalid URL '\(String(describing: opts.url))'.")
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .useProtocolCachePolicy
        
        // create the client
        let client = HTTPClient(host: host) {
            $0.sessionConfiguration = sessionConfig
        }
        
        // create the request
        let req: HTTPRequest<Data> = HTTPRequest.get(url.path, query: nil, headers: nil)

        if isVerbose { print(String(describing: req)) }

        // perform the request
        let resp = try await client.data(for: req)

        if isVerbose { print(String(describing: resp)) }

        // parse the response data
        let json = try resp.value.toJson(prettyPrinted: true)

        print(json)
    }
}

