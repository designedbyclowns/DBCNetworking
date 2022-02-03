import Foundation

extension HTTPURLResponse {
    /// The ``HTTPStatus`` of the response.
    var status: HTTPStatus? {
        HTTPStatus(rawValue: statusCode)
    }
}

extension HTTPURLResponse {
    /// Simple user friendly description: E.G. "200 OK"
    public override var description: String {
        "\(statusCode) \(HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized)"
    }
}

extension HTTPURLResponse {
    /// A description suitable for logging
    public var logDescription: String {
        var components: [String] = []

        components.append("<\(type(of: self))> \(statusCode) \(Self.localizedString(forStatusCode: statusCode))")

        var props: [String: Any] = [:]
        props["url"] = url?.absoluteString
        props["mimeType"] = mimeType
        props["textEncoding"] = textEncodingName
        props["expectedContentLength"] = expectedContentLength
        props["headers"] = Dictionary(uniqueKeysWithValues: allHeaderFields.map { ("\($0)", $1) })

        components.append(String(describing: props))
        return components.joined(separator: ", ")
    }
}
