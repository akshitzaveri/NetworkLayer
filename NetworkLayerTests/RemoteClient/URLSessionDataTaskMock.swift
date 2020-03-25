//
//  MockTask.swift
//  NetworkLayerTests
//
//  Created by Akshit Zaveri on 24/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation
@testable import NetworkLayer

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {

  private(set) var resumeWasCalled = false

  func resume() {
    self.resumeWasCalled = true
  }
}
