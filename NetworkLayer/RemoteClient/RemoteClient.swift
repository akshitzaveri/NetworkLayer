//
//  RemoteClient.swift
//  NetworkLayer
//
//  Created by Akshit Zaveri on 24/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
  typealias DataTaskResult = (
    Data?,
    URLResponse?,
    Error?
    ) -> Void

  func dataTask(
    with request: URLRequest,
    completionHandler: @escaping DataTaskResult
  ) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
  func dataTask(
    with request: URLRequest,
    completionHandler: @escaping DataTaskResult
  ) -> URLSessionDataTaskProtocol {
    return (
      self.dataTask(
        with: request,
        completionHandler: completionHandler
        ) as URLSessionDataTask)
      as URLSessionDataTaskProtocol
  }
}

protocol URLSessionDataTaskProtocol {
  func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

/// <#Description#>
final class RemoteClient {

  private enum HTTPCode {
    static let notAuthorised = "401"
    static let internalServerError = "500"
    static let responseOK = "200"
  }

  /// <#Description#>
  enum Result<V, RemoteClientError: Error> {
    case success(V)
    case failure(RemoteClientError)
  }

  /// <#Description#>
  enum Failure: Error {
    case emptyData
    case invalidJSON
    case invalidURL
    case notAuthorized(String)
  }

  /// <#Description#>
  var session: URLSessionProtocol

  /// <#Description#>
  /// - Parameter session: <#session description#>
  init(session: URLSessionProtocol = URLSession.shared) { self.session = session }

  /// <#Description#>
  /// - Parameters:
  ///   - endpoint: <#endpoint description#>
  ///   - decodingType: <#decodingType description#>
  ///   - completion: <#completion description#>
  func fetch<DecodableType>(
    _ endpoint: EndpointType,
    decodingType: DecodableType.Type,
    completion: @escaping (Result<DecodableType, Failure>) -> Void
  ) where DecodableType: Decodable {
    guard let url = endpoint.urlRequest.url, url.isValid() else {
      completion(.failure(.invalidURL))
      return
    }

    self.printEndpoint(endpoint)

    let task = session.dataTask(with: endpoint.urlRequest) { (data, _, error) in
      guard let data = data else {
        completion(.failure(.emptyData))
        return
      }
      do {
        let decoder = JSONDecoder()
        let decodableModel = try decoder.decode(decodingType, from: data)

        if let model = decodableModel as? EndpointResponseProtocol {
          if model.code == HTTPCode.notAuthorised {
            let message = model.message ?? "Unknown error."
            completion(.failure(.notAuthorized(message)))
            return
          }
        }

        completion(.success(decodableModel))
      } catch {
        self.printData(data)
        print("URL: \(url)")
        print("JSON Conversion failed \(error)")
        completion(.failure(.invalidJSON))
      }
    }
    task.resume()
  }

  private func printEndpoint(_ endpoint: EndpointType) { endpoint.printFullDescription() }

  private func printData(_ data: Data?) {
    guard let data = data else {
      print("NO DATA FOUND FOR THE API RESPONSE")
      return
    }
    guard let string = String(data: data, encoding: .utf8) else {
      print("DATA TO STRING CONVERSION FAILED")
      return
    }
    print(string)
  }
}

extension RemoteClient.Failure: Equatable { }
