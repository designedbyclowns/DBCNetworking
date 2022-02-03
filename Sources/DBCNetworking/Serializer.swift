import Foundation

/// An Actor for encoding & decoding types.
actor Serializer {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(decoder: JSONDecoder? = nil, encoder: JSONEncoder? = nil) {
        self.decoder = decoder ?? JSONDecoder.httpDecoder
        self.encoder = encoder ?? JSONEncoder.httpEncoder
    }
    
    /// Decodes data as a Decodable type.
    /// - Returns: An instance of the specified type.
    func decode<T: Decodable>(_ data: Data) async throws -> T {
        try decoder.decode(T.self, from: data)
    }
    /// Encode an Encodable type.
    /// - Returns: The encoded data.
    func encode<T: Encodable>(_ entity: T) async throws -> Data {
        try encoder.encode(entity)
    }
}

private extension JSONDecoder {
    /// Default JSONDecoder for HTTP requests & responses.
    static var httpDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension JSONEncoder {
    /// Default JSONEncoder for HTTP requests.
    static var httpEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
