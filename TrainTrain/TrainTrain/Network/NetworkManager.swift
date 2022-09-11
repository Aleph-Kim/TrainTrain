import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/5/"

  /// 특정 지하철역을 기준으로, 다음 지하철역으로 향하는 실시간 도착정보를 배열 형태로 가져옵니다.
  /// - Parameter targetStationName: 실시간 도착정보의 기준이 되는 지하철역의 이름
  /// - Parameter nextStationName: 다음 지하철역의 이름 - 이동 방향을 파악하기 위해 필요합니다.
  /// - Returns: 실시간 도착정보의 배열
  func fetch(targetStationName: String, nextStationName: String) async -> [ArrivalInfo]? {
    var targetStationName = targetStationName
    var nextStationName = nextStationName

    if targetStationName.last == "역" {
      targetStationName.removeLast()
    }

    if nextStationName.last == "역" {
      nextStationName.removeLast()
    }

    do {
      let trainInfo = try await fetch(stationName: targetStationName)
      print("📡 통신 상태값 -> status: \(trainInfo.errorMessage.code), message: \(trainInfo.errorMessage.message), total: \(trainInfo.errorMessage.total)")

      let filteredList = trainInfo.realtimeArrivalList.filter { $0.trainDestination.contains(nextStationName) }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return nil
    }
  }

  private func fetch(stationName: String) async throws -> TrainInfo {
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
