//
//  Endpoint.swift
//  NetworkLayer
//
//  Created by Akshit Zaveri on 24/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation

/// <#Description#>
enum EndpointRequestHTTPMethod: String {
  case GET
  case POST
  case DELETE
  case PUT
}

/// <#Description#>
protocol EndpointResponseProtocol {
  var code: String { get }
  var status: String { get }
  var message: String? { get }
}

private enum Constants {
  static let timeoutInterval: TimeInterval = 500
}

protocol EndpointType {

  typealias RequestParametersType = [String: Any]

  /// <#Description#>
  func getRequestParameters() -> RequestParametersType?

  /// <#Description#>
  //    var response: EndpointResponse? { get }

  /// <#Description#>
  var httpMethod: EndpointRequestHTTPMethod { get }

  /// <#Description#>
  var base: String { get }

  /// <#Description#>
  var path: String { get }

  /// <#Description#>
  var authenticationToken: String? { get }

  /// <#Description#>
  var contentType: String? { get }

  /// <#Description#>
  var contentLength: String? { get }

  /// <#Description#>
  func getBodyData() -> Data?
}

extension EndpointType {

  // swiftlint:disable force_try
  var base: String { "" }
  // swiftlint:enable force_try

  var urlComponents: URLComponents {
    var components = URLComponents(string: self.base)!
    components.path += self.path

    if self.httpMethod == .GET {
      components.queryItems = []
      for requestParameter in self.getRequestParameters() ?? [:] {
        var stringValue = ""
        if let value = requestParameter.value as? String {
          stringValue = value
        } else {
          stringValue = String(describing: requestParameter.value)
        }

        let queryItem = URLQueryItem(name: requestParameter.key, value: stringValue)
        components.queryItems?.append(queryItem)
      }
    }

    return components
  }

  ///
  var urlRequest: URLRequest {
    let url = self.urlComponents.url!
    var req = URLRequest(url: url)
    req.timeoutInterval = Constants.timeoutInterval
    req.httpMethod = self.httpMethod.rawValue

    if self.httpMethod == .POST {
      if let bodyData = self.getBodyData() {
        req.httpBody = bodyData
      } else {
        if let parameters = self.getRequestParameters() {
          let string = parameters
            .map({ return "\($0)=\($1)" })
            .joined(separator: "&")
          req.httpBody = string.data(using: .utf8, allowLossyConversion: false)
        }
      }
    }

    if let authToken = self.authenticationToken, authToken.count > 0 {
      req.addValue(authToken, forHTTPHeaderField: "Authorization")
      print("Auth token added \(authToken)")
    }

    if let contentType = self.contentType {
      req.addValue(contentType, forHTTPHeaderField: "Content-Type")
      print("ContentType \(contentType)")
    }

    if let contentLength = self.contentLength {
      req.addValue(contentLength, forHTTPHeaderField: "Content-Length")
      print("ContentLength \(contentLength)")
    }

    return req
  }

  var httpMethod: EndpointRequestHTTPMethod { .GET }
  var authenticationToken: String? { nil }
  var contentType: String? { "application/x-www-form-urlencoded" }
  var contentLength: String? { nil }
  func getBodyData() -> Data? { nil }

  func printFullDescription() {
    print("**************************")
    print(self.getRequestParameters() ?? [:])
    print(self.urlRequest.description)
    print("HTTPBody Length \(self.urlRequest.httpBody?.count ?? 0)")
    print("**************************")
  }
}
