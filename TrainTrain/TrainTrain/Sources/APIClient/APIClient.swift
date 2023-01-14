//
//  APIClient.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation

typealias APIResponse = (data: Data, urlResponse: URLResponse)

struct APIClient<APIRoute: APIRoutable> {
  var request: @Sendable (APIRoute) async throws -> APIResponse

  func request(_ route: APIRoute) async throws -> APIResponse {
    return try await request(route)
  }

  func request<Decoded: Decodable>(_ route: APIRoute, as: Decoded.Type) async throws -> Decoded {
    let (data, _) = try await request(route)

    do {
      return try decode(Decoded.self, from: data)
    } catch {
      throw error
    }
  }

  private func decode<Decoded: Decodable>(
    with decoder: JSONDecoder = JSONDecoder(),
    _ type: Decoded.Type,
    from data: Data
  ) throws -> Decoded {
    do {
      return try decoder.decode(Decoded.self, from: data)
    } catch {
      throw error
    }
  }
}
