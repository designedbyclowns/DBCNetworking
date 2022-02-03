import Foundation

/// A simple URLSession wrapper adding async/await APIs compatible with older platforms.
final class DataLoader: NSObject, URLSessionDataDelegate {
    
    /// Loads data with the given request.
    func data(for request: URLRequest,
              session: URLSession) async throws -> (Data, URLResponse, URLSessionTaskMetrics?) {
        final class TaskWrapper { var task: URLSessionTask? }
        let wrapper = TaskWrapper()
        
        return try await withTaskCancellationHandler(handler: {
            wrapper.task?.cancel()
        }, operation: {
            try await withUnsafeThrowingContinuation { continuation in
                wrapper.task = self.loadData(with: request, session: session) { result in
                    continuation.resume(with: result)
                }
            }
        })
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let handler = handlers[task] else { return }
        
        handlers[task] = nil
        
        if let response = task.response, error == nil {
            handler.completion(.success((handler.data, response, handler.metrics)))
        } else {
            handler.completion(.failure(error ?? URLError(.unknown)))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        handlers[task]?.metrics = metrics
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let handler = handlers[dataTask] else { return }
        handler.data.append(data)
    }
    
    // MARK: - Private
    
    private var handlers: [URLSessionTask: TaskHandler] = [:]
    private typealias Completion = (Result<(Data, URLResponse, URLSessionTaskMetrics?), Error>) -> Void
    
    private func loadData(with request: URLRequest,
                          session: URLSession,
                          completion: @escaping Completion) -> URLSessionTask {
        let task = session.dataTask(with: request)
        
        session.delegateQueue.addOperation {
            self.handlers[task] = TaskHandler(completion: completion)
        }
        
        task.resume()
        return task
    }
}

// MARK: - TaskHandler

extension DataLoader {
    private final class TaskHandler {
        var data: Data = Data()
        var metrics: URLSessionTaskMetrics?
        let completion: Completion

        init(completion: @escaping Completion) {
            self.completion = completion
        }
    }
}
