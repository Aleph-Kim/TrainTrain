//
//  APIClientLive.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation

extension APIClient {
  static func live(session: URLSession = .shared) -> Self {
    @Sendable func printRequest(_ request: URLRequest) {
      print(
        """
        🟨 Request route: \(request.httpMethod ?? "") \(request.url!)
        """
      )
    }
    @Sendable func printAPI(
      request: URLRequest,
      response: (data: Data, urlResponse: URLResponse)
    ) {
      print(
        """
        ✅ Response route: \(request.httpMethod ?? "") \(request.url!), \
        status: \((response.urlResponse as? HTTPURLResponse)?.statusCode ?? 0), \
        receive data: \(response.data.asPrettyPrinted ?? ""))
        """
      )
    }
    return Self(
      request: { route in
        let urlRequest = URLRequest(route: route)
        #if DEBUG
        printRequest(urlRequest)
        #endif
        let (data, response) = try await session.data(for: urlRequest)
        #if DEBUG
        printAPI(request: urlRequest, response: (data, response))
        #endif
        return (data, response)
      }
    )
  }
}

fileprivate extension URLRequest {
  init(route: APIRoutable) {
    self.init(url: route.baseURL.appendingPathComponent(route.route.path))
    self.httpMethod = route.route.method.rawValue
    self.allHTTPHeaderFields = route.headers
  }
}

fileprivate extension Data {
  var asPrettyPrinted: String? {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
          let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
          let stringified = String(data: data, encoding: .utf8) else { return nil }
    return stringified
  }
}
