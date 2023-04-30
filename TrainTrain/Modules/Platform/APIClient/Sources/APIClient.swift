//
//  APIClient.swift
//  TrainTrain
//
//  Created by Geonhee on 2022/12/24.
//

import Foundation

public typealias APIResponse = (data: Data, urlResponse: URLResponse)

public struct APIClient {
  public var request: @Sendable (APIRoutable) async throws -> APIResponse

  public init(
    request: @Sendable @escaping (APIRoutable) async throws -> APIResponse
  ) {
    self.request = request
  }

  public func request(_ route: APIRoutable) async throws -> APIResponse {
    return try await request(route)
  }

  public func request<Decoded: Decodable>(_ route: APIRoutable, as: Decoded.Type) async throws -> Decoded {
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
