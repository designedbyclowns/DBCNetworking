# DBCNetworking

A simple networking library for making HTTP requests.

## Requirements

* Xcode [13.2.1](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_13.2.1/Xcode_13.2.1.xip), or later, is required in order to use swift concurrency with iOS 13 & 14.

## Documentation

You can view documentation, such as it is, directly in Xcode.

### Generate Documentation

1. Select the `DBCNetworking` scheme.
2. Choose the `Product > Build Documentation` menu item.
3. This will open the Documentation viewer where you can access the documentation for DBCNetworking.

Documentation will also be available in all the usual Xcode places.

## Overview

It makes use of Swift's new [concurrency](https://gist.github.com/lattner/31ed37682ef1576b16bca1432ea9f782) [model](https://developer.apple.com/documentation/swift/swift_standard_library/concurrency), featuring async/await and actors.


Currently the two main components are ``HTTPClient`` and ``HTTPClientDelegate``, as well as an example command line tool just for fun.

There is also a ``MockHTTPClientProtocol`` to facilitate testing. See ``HTTPClientTests.swift`` for an example.

#### HTTPClient

HTTPClient provides a very simple API to create custom clients for any service. It can even be use completely inline.

Example of a simple HTTP request for a response of type Data:

```swift
let client = HTTPClient(host: "swapi.dev")

do {
    let resp: Data = try await client.send(.get("/api/people/13"))
    print(resp.value.toJson)
} catch {
    print(String(describing: error))
}

```

See ``HTTPClientTests`` for a more detailed example.


#### HTTPClientDelegate

This is an optional delegate that provides a variety of hooks to interact with the HTTP request/response cycle.


### Testing

A custom URL Protocol, ``MockHTTPClientProtocol``, is provided to facilitate testing clients. See ``HTTPClientTests`` for example usage.

### HTTPTool

This package also includes an executable target that creates a command line tool that can be handy to use when exploring HTTP services.

#### Usage

Build and run

```
% swift run http-tool   

[0/0] Build complete!
Error: Invalid URL 'nil'.

OVERVIEW: GETs a URL

Performs an HTTP GET request to load the specified URL.

USAGE: get [--verbose] <url>

ARGUMENTS:
  <url>                   The request URL

OPTIONS:
  -v, --verbose
  -h, --help              Show help information.

```

Alternatively you can run it in Xcode by selecting the `http-tool` scheme, with your Mac as the destination. Arguments can be provided in the **Arguments** tab of the **Run** section in the scheme editor. E.G. `https://swapi.dev/api/people/13/`.


### Authentication

By design, this library provides no specific implementation for authentication. That logic is best left to the applications that utilize the library.

That being said, there are multiple approaches to do so, especially when using an authentication request header. Each has somewhat different use case.

1. Per session. include the Authentication header in a custom ``URLSessionConfiguration`` when configuring the ``HTTPClient``. This will apply to all request for that session.
2. Per request. include it in the headers property of an ``HTTPRequest<Response>``. This only autheticates the specific request.
3. Using a delegate. ``HTTPClientDelegate`` provides an opportunity to modify each request before it is sent. This allows you to add any custom logic about how and why to authenticate the specific request. It also allows the authentication logic to be completely independent from the client.
4. Using a custom ``URLSessionDelegate``. This provides a way to respond to request challenges, though that is uncommon for web services.

## Prerequisites

Xcode [13.2.1](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_13.2.1/Xcode_13.2.1.xip), or later, is required in order to use swift concurrency with iOS 13 & 14.

## Dependencies

### HTTPTool

#### Swift Argument Parser

- Straightforward, type-safe argument parsing for Swift.
- https://github.com/apple/swift-argument-parser
- License: [Apache License 2.0](https://github.com/apple/swift-argument-parser/blob/main/LICENSE.txt)


## TODO

This is still a work in progress, but I think it's ready for use. Here are some of the other things I am still working on:

* Logging.
* File downloads (with pause and resume).
* Consume a future authentication service.
* Native support for additional request body types (including multipart uploads).
* Whatever else all y'all want.

