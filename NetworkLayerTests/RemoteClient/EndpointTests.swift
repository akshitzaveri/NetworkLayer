//
//  EndpointTests.swift
//  NetworkLayerTests
//
//  Created by Akshit Zaveri on 25/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import XCTest
@testable import NetworkLayer

class EndpointTests: XCTestCase {

  func test_WhenInitializedGETRequest_ThenItHasValues() {
    // given & when
    let endpoint = GETEndpointMock()

    // then
    XCTAssertEqual(endpoint.getRequestParameters()!.count, 2)
    XCTAssertEqual(endpoint.getRequestParameters()!["param"] as? String, "value")
    XCTAssertEqual(endpoint.getRequestParameters()!["param1"] as? Int, 5)

    XCTAssertEqual(endpoint.httpMethod, .GET)
    XCTAssertEqual(endpoint.base, "https://google.com")
    XCTAssertEqual(endpoint.path, "/assets")
    XCTAssertEqual(endpoint.authenticationToken, "AUTH_TOKEN")
    XCTAssertEqual(endpoint.contentType, "app/html")
    XCTAssertNil(endpoint.contentLength)
    XCTAssertNil(endpoint.getBodyData())

    // Can not test the URL because of the dictionary randomizing the sequence of the keys
    // XCTAssertEqual(endpoint.urlRequest.url, URL(string: "https://google.com/assets?param=value&param1=value1")!)

    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "Authorization"), "AUTH_TOKEN")
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "content-type"), "app/html")
    XCTAssertNil(endpoint.urlRequest.value(forHTTPHeaderField: "Content-Length"))
  }

  func test_WhenInitializedPOSTRequestWithBodyData_ThenItHasValues() {
    // given & when
    let endpoint = POSTEndpointMock(body: Data())

    // then
    XCTAssertEqual(endpoint.httpMethod, .POST)
    XCTAssertEqual(endpoint.base, "https://google.com")
    XCTAssertEqual(endpoint.path, "/assets")
    XCTAssertEqual(endpoint.authenticationToken, "AUTH_TOKEN")
    XCTAssertEqual(endpoint.contentType, "app/json")
    XCTAssertEqual(endpoint.contentLength, "111")
    XCTAssertEqual(endpoint.getBodyData(), Data())

    // Request parameters (queryItems) will not be added into the URL
    // due to the request being POST and it has a non-nil bodyData
    XCTAssertEqual(endpoint.urlRequest.url, URL(string: "https://google.com/assets")!)

    XCTAssertNotNil(endpoint.urlRequest.httpBody)
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "Authorization"), "AUTH_TOKEN")
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "content-type"), "app/json")
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "Content-Length"), "111")

  }

  func test_WhenInitializedPOSTRequestWithoutBodyData_ThenItHasValues() {
    // given & when
    let endpoint = POSTEndpointMock()

    // then
    XCTAssertEqual(endpoint.httpMethod, .POST)
    XCTAssertEqual(endpoint.base, "https://google.com")
    XCTAssertEqual(endpoint.path, "/assets")
    XCTAssertEqual(endpoint.authenticationToken, "AUTH_TOKEN")
    XCTAssertEqual(endpoint.contentType, "app/json")
    XCTAssertNil(endpoint.contentLength)
    XCTAssertNil(endpoint.getBodyData())

    // Request parameters (queryItems) will be added into the bodyData
    // due to the request being POST and it has a nil bodyData
    XCTAssertNotNil(endpoint.urlRequest.httpBody)

    XCTAssertEqual(endpoint.urlRequest.url, URL(string: "https://google.com/assets")!)
    XCTAssertNotNil(endpoint.urlRequest.httpBody)
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "Authorization"), "AUTH_TOKEN")
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "content-type"), "app/json")
    XCTAssertEqual(endpoint.urlRequest.value(forHTTPHeaderField: "Content-Length"), nil)
  }
}

private class GETEndpointMock: EndpointType {
  func getRequestParameters() -> GETEndpointMock.RequestParametersType? { [ "param": "value", "param1": 5 ] }
  var httpMethod: EndpointRequestHTTPMethod { .GET }
  var base: String { "https://google.com" }
  var path: String { "/assets" }
  var authenticationToken: String? { "AUTH_TOKEN" }
  var contentType: String? { "app/html" }
  var contentLength: String? { nil }
  func getBodyData() -> Data? { nil }
}

private class POSTEndpointMock: EndpointType {
  private let bodyData: Data?
  init(body: Data? = nil) {
    bodyData = body
  }

  func getRequestParameters() -> POSTEndpointMock.RequestParametersType? { [ "param": "value" ] }
  var httpMethod: EndpointRequestHTTPMethod { .POST }
  var base: String { "https://google.com" }
  var path: String { "/assets" }
  var authenticationToken: String? { "AUTH_TOKEN" }
  var contentType: String? { "app/json" }
  var contentLength: String? {
    if bodyData != nil { return "111" }
    else { return nil }
  }
  func getBodyData() -> Data? { bodyData }
}
