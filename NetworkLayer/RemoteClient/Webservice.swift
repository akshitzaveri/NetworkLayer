//
//  Webservice.swift
//  NetworkLayer
//
//  Created by Akshit Zaveri on 25/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation

typealias WebserviceWillStartHandler = () -> Void

class Webservice {

  var remoteClient: RemoteClient!

  /// <#Description#>
  /// - Parameter remoteClient: <#remoteClient description#>
  init(remoteClient: RemoteClient = RemoteClient()) {
    self.remoteClient = remoteClient
  }
}
