import Foundation

/**
 HTTP Request Method

 The request method token is the primary source of request semantics; it indicates the purpose for which the client
 has made this request and what is expected by the client as a successful result.

 This specification defines a number of standardized methods that are commonly used in HTTP. By convention,
 standardized methods are defined in all-uppercase US-ASCII letters.

 - [RFC 7231](https://datatracker.ietf.org/doc/html/rfc7231#section-4)
 - [RFC 5789](https://datatracker.ietf.org/doc/html/rfc5789)
 */
public enum RequestMethod: String {
    /// The GET method requests transfer of a current selected representation for the target resource.
    case get = "GET"
    /// The HEAD method is identical to GET except that the server __MUST NOT__ send a message body in the response.
    case head = "HEAD"
    /// The POST method requests that the target resource process the representation enclosed in the request
    /// according to the resource's own specific semantics
    case post = "POST"
    /// The PUT method requests that the state of the target resource be created or replaced with the state
    /// defined by the representation enclosed in the request message payload.
    case put = "PUT"
    /// The DELETE method requests that the origin server remove the association between the target resource and
    /// its current functionality.
    case delete = "DELETE"
    /// The CONNECT method requests that the recipient establish a tunnel to the destination origin server
    /// identified by the request-target and, if successful, thereafter restrict its behavior to blind forwarding
    /// of packets, in both directions, until the tunnel is closed.
    case connect = "CONNECT"
    /// The OPTIONS method requests information about the communication options available for the target resource,
    /// at either the origin server or an intervening intermediary.
    case options = "OPTIONS"
    /// The TRACE method requests a remote, application-level loop-back of the request message.
    case trace = "TRACE"
    /// The PATCH method requests that a set of changes described in the request entity be applied to the resource
    /// identified by the Request-URI.
    ///
    /// The difference between the PUT and PATCH requests is reflected in the way the server processes the enclosed
    /// entity to modify the resource identified by the Request-URI.  In a PUT request, the enclosed entity is
    /// considered to be a modified version of the resource stored on the origin server, and the client is
    /// requesting that the stored version be replaced.  With PATCH, however, the enclosed entity contains a set of
    /// instructions describing how a resource currently residing on the origin server should be modified to
    /// produce a new version.
    case patch = "PATCH"
}

public extension RequestMethod {
    /// Request methods are considered _safe_ if their defined semantics are essentially read-only; i.e., the
    /// client does not request, and does not expect, any state change on the origin server as a result of
    /// applying a safe method to a target resource.
    var isSafe: Bool {
        switch self {
        case .get, .head, .options, .trace:
            return true
        case .post,.put, .delete, .connect, .patch:
            return false
        }
    }

    /// A request method is considered "idempotent" if the intended effect on the server of multiple identical
    /// requests with that method is the same as the effect for a single such request.  Of the request methods
    /// defined by this specification, PUT, DELETE, and safe request methods are idempotent.
    var isIdempotent: Bool {
        switch self {
        case .get, .head, .put, .delete, .options, .trace:
            return true
        case .post, .connect, .patch:
            return false
        }
    }

    /// A request method is cacheable if responses to requests with that method may be stored for future reuse.
    var isCacheable: Bool {
        switch self {
        case .get, .head, .post:
            return true
        case .put, . delete, .connect, .options, .trace, .patch:
            return false
        }
    }

    var requestBodyIsRequired: Bool {
        switch self {
        case .post, .put, .patch:
            return true
        case .get, .head, .delete, .connect, .options, .trace:
            return false
        }
    }

    var requestBodyIsAllowed: Bool {
        switch self {
        case .get, .head, .post, .put, .delete, .connect, .options, .patch:
            return true
        case  .trace:
            return false
        }
    }

    var hasResponseBody: Bool {
        switch self {
        case .get, .post, .put, .delete, .connect, .options, .trace, .patch:
            return true
        case  .head:
            return false
        }
    }
}
