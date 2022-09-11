import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/5/"

  func execute(stationName: String) async throws -> TrainInfo {
    guard let urlRequest = urlRequest(stationName: stationName) else {
      throw APIError.invalidURLRequest
    }

    let (data, response) = try await URLSession.shared.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidServerResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      print("⚠️ Status Code -> \(httpResponse.statusCode)")
      throw APIError.invalidServerResponse
    }

    let decodedData = try JSONDecoder().decode(TrainInfo.self, from: data)

    return decodedData
  }

  private func urlRequest(stationName: String) -> URLRequest? {
    let urlComponents = URLComponents(string: baseURLString + stationName)

    guard let url = urlComponents?.url else {
      return nil
    }

    return URLRequest(url: url)
  }
}
