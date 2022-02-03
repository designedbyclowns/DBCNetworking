import Foundation

extension Data {
    /// Convert Data to a JSON String
    /// - Parameter prettyPrinted: If true, the JSON will be formatted pretty.
    /// - Throws: An error if the data can't be read, or is not valid JSON.
    /// - Returns: The JSON string
    public func toJson(prettyPrinted: Bool = false) throws -> String {
        // verify we have valid json
        let object = try JSONSerialization.jsonObject(with: self, options: [])

        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted { options.insert(.prettyPrinted) }

        // Remove all that pesky forward slash escaping
        if #available(iOS 13.0, macOS 10.15, *) {
            options.insert(.withoutEscapingSlashes)
        }

        let json = try JSONSerialization.data(withJSONObject: object, options: options)
        return String(decoding: json, as: UTF8.self)
    }
}

extension Data {
    /// A description suitable for logging
    public var logDescription: String {
        return Self.byteFormatter.string(fromByteCount: Int64(count))
    }

    private static var byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.includesActualByteCount = true
        return formatter
    }()
}
