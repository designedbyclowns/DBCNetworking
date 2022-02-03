import Foundation

/**
 A media type (formerly known as MIME type) is a two-part identifier for file formats and format contents
 transmitted on the Internet.

 A media type consists of a type and a subtype, which is further structured into a tree. A media type can
 optionally define a suffix and parameters:

 ```
 type "/" [tree "."] subtype ["+" suffix]* [";" parameter]
 ```

 As an example, an HTML file might be designated `text/html; charset=UTF-8`. In this example, `text` is the type,
 `html` is the subtype, and `charset=UTF-8` is an optional parameter indicating the character encoding.
 
 - NOTE: Extend MediaType as needed to provide type safe, named media types.
 */
public struct MediaType: Hashable, CustomStringConvertible {
    let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
}

extension MediaType {
    static let applicationJson = Self("application/json")
    static let applicationJsonCharsetUTF8 = Self("application/json; charset=utf-8")
}
