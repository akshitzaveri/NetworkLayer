//
//  RemoteClientTests.swift
//  NetworkLayerTests
//
//  Created by Akshit Zaveri on 24/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import XCTest
@testable import NetworkLayer

class RemoteClientTests: XCTestCase {

  var sut: RemoteClient!

  override func tearDown() {
    sut = nil
  }

  private func getSubjectUnderTest(from jsonFile: String? = nil) -> RemoteClient {
    let sut = RemoteClient()
    var mockData: Data?
    if let fileName = jsonFile { mockData = getDataFromJSON(in: fileName) }
    sut.session = URLSessionMock(data: mockData, urlResponse: nil, error: nil)
    return sut
  }

  func test_MockWebservice_ReturnsDecodableObject() {
    // given
    sut = getSubjectUnderTest(from: "TestMockDataResponse")
    let endpoint = EndpointMock()
    let promise = expectation(description: "API Response expectation")

    // when
    var receivedValue: DecodableMock?
    sut.fetch(endpoint, decodingType: DecodableMock.self, completion: { result in
      switch result {
      case .success(let value): receivedValue = value
      case .failure: assertionFailure("Failure should be nil")
      }
      promise.fulfill()
    })

    // then
    waitForExpectations(timeout: CommonConstants.expectationTimeoutInterval, handler: nil)

    XCTAssertNotNil(receivedValue)
  }

  func test_MockWebservice_ReturnsInvalidJSONError() {
    // given
    sut = getSubjectUnderTest(from: "TestMockDataResponse_InvalidJSONError")
    let endpoint = EndpointMock()
    let promise = expectation(description: "API Response expectation")

    // when
    var receivedError: RemoteClient.Failure?
    sut.fetch(endpoint, decodingType: DecodableMock.self, completion: { result in
      switch result {
      case .success: assertionFailure("Value should be nil")
      case .failure(let error): receivedError = error
      }
      promise.fulfill()
    })

    // then
    waitForExpectations(timeout: CommonConstants.expectationTimeoutInterval, handler: nil)

    XCTAssertNotNil(receivedError)
    XCTAssertEqual(receivedError, .invalidJSON)
  }

  func test_MockWebservice_ReturnsNotAuthorizedJSONError() {
    // given
    sut = getSubjectUnderTest(from: "TestMockDataResponse_NotAuthorizedJSONError")
    let endpoint = EndpointMock()
    let promise = expectation(description: "API Response expectation")

    // when
    var receivedError: RemoteClient.Failure?
    sut.fetch(endpoint, decodingType: DecodableMock.self, completion: { result in
      switch result {
      case .success: assertionFailure("Value should be nil")
      case .failure(let error): receivedError = error
      }
      promise.fulfill()
    })

    // then
    waitForExpectations(timeout: CommonConstants.expectationTimeoutInterval, handler: nil)

    XCTAssertNotNil(receivedError)
    XCTAssertEqual(receivedError, .notAuthorized("Not Authorized"))
  }

  func test_MockWebservice_ReturnsEmptyDataError() {
    // given
    sut = getSubjectUnderTest()
    let endpoint = EndpointMock()
    let promise = expectation(description: "API Response expectation")

    // when
    var receivedError: RemoteClient.Failure?
    sut.fetch(endpoint, decodingType: DecodableMock.self, completion: { result in
      switch result {
      case .success: assertionFailure("Value should be nil")
      case .failure(let error): receivedError = error
      }
      promise.fulfill()
    })

    // then
    waitForExpectations(timeout: CommonConstants.expectationTimeoutInterval, handler: nil)

    XCTAssertNotNil(receivedError)
    XCTAssertEqual(receivedError, .emptyData)
  }

  func test_MockWebservice_ReturnsInvalidURLError() {
    // given
    sut = getSubjectUnderTest()
    let endpoint = InvalidURLEndpoint()
    let promise = expectation(description: "API Response expectation")

    // when
    var receivedError: RemoteClient.Failure?
    sut.fetch(endpoint, decodingType: DecodableMock.self, completion: { result in
      switch result {
      case .success: assertionFailure("Value should be nil")
      case .failure(let error): receivedError = error
      }
      promise.fulfill()
    })

    // then
    waitForExpectations(timeout: CommonConstants.expectationTimeoutInterval, handler: nil)

    XCTAssertNotNil(receivedError)
    XCTAssertEqual(receivedError, .invalidURL)
  }
}

private class EndpointMock: EndpointType {
  func getRequestParameters() -> EndpointMock.RequestParametersType? { [:] }
  var path: String = ""
  var base: String = "https://google.com"
}

final class DecodableMock: Decodable, EndpointResponseProtocol {
  var code: String
  var status: String
  var message: String?
}

private class InvalidURLEndpoint: EndpointType {
  func getRequestParameters() -> InvalidURLEndpoint.RequestParametersType? { [:] }
  var path: String = ""
  var base: String = "google.com1"
}
