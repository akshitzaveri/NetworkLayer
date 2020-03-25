//
//  MockURLSession.swift
//  NetworkLayerTests
//
//  Created by Akshit Zaveri on 24/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation
@testable import NetworkLayer

class URLSessionMock: URLSessionProtocol {

  var nextDataTask = URLSessionDataTaskMock()
  private var data: Data?
  private var urlResponse: URLResponse?
  private let taskError: Error?

  init(data: Data?, urlResponse: URLResponse?, error: Error?) {
    self.data = data
    self.urlResponse = urlResponse
    self.taskError = error
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
    completionHandler(self.data, self.urlResponse, self.taskError)
    return self.nextDataTask
  }
}
