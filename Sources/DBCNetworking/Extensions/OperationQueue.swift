import Foundation

extension OperationQueue {
    /// Creates an OperationQueue with he supplied maximum concurrent operation count.
    convenience init(maxConcurrentOperationCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
}
