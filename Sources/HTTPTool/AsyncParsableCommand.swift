import Foundation
import ArgumentParser

/**
 Swift 5.5 supports an asynchronous main function, but ArgumentParser (as of version 1.0.2) does not.

 This protocol defines a `runAsync()`function to allow using `async` with command line tools.
 */
@available(macOS 12.0, *)
protocol AsyncParsableCommand: ParsableCommand {
    mutating func runAsync() async throws
}

extension ParsableCommand {
    /// Extends `ParsableCommand` with an `async` variant.
    ///
    /// Provides conditional compatibility with `@main async`.
    static func main(_ arguments: [String]? = nil) async {
        do {
            var command = try parseAsRoot(arguments)
            if #available(macOS 12.0, *), var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.runAsync()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
}
