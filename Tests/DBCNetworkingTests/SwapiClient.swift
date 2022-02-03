import Foundation
import DBCNetworking

struct SwapiPeople: Decodable {
    let birthYear: String
    let created: Date
    let edited: Date
    let eyeColor: String
    let films: [String]
    let gender: String
    let hairColor: String
    let height: String
    let homeworld: String
    let mass: String
    let name: String
    let skinColor: String
    let species: [String]
    let starships: [String]
    let url: String
    let vehicles: [String]
}

final class SwapiClient {

    let client: HTTPClient
    
    init() {
        self.client = HTTPClient(host: "https://swapi.dev") {
            $0.decoder = Self.decoder
            $0.delegate = SwapiClientDelegate()
            $0.sessionConfiguration = .ephemeral
        }
    }
    
    func getPeople(_ peopleId: Int) async throws -> SwapiPeople {
        let req: HTTPRequest<SwapiPeople> = HTTPRequest.get("api/people/\(peopleId)/")
        return try await client.send(req).value
    }
}

private final class SwapiClientDelegate: HTTPClientDelegate {
    
}

extension SwapiClient {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // E.G. "2014-12-10T16:42:45.066000Z"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return formatter
    }()
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
}
