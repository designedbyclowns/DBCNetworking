import Foundation
import ArgumentParser
import DBCNetworking

@main
struct HTTPTool {

    static var configuration = CommandConfiguration(
        abstract: "HTTPClient command line tool.",
        discussion: """
        A utility to perform network requests via the HTTPClient library.
        """,
        subcommands: [
            Get.self
        ],
        defaultSubcommand: Get.self
    )
    
    struct Options: ParsableArguments {

        @Flag(name: .shortAndLong)
        var verbose: Bool = false

        @Argument(help: "The request URL", transform: { URL(string: $0) }
        ) var url: URL?

        mutating func validate() throws {
            guard url?.host != nil else { throw ValidationError("Invalid URL '\(String(describing: url))'.") }
        }
    }
    
    static func main() async {
        await Get.main()
    }
}
