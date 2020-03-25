//
//  URL+Validation.swift
//  NetworkLayer
//
//  Created by Akshit Zaveri on 25/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation

extension URL {

  /// <#Description#>
  func isValid() -> Bool {
    let input = self.absoluteString
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
      return false
    }
    let range = NSRange(location: 0, length: input.utf16.count)
    let matches = detector.matches(in: input, options: [], range: range)
    for match in matches {
      guard Range(match.range, in: input) != nil else { continue }
      return true
    }
    return false
  }
}
