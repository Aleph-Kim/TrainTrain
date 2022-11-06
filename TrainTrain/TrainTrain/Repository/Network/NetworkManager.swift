import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/5/"

  /// 특정 지하철역을 기준으로, 이전 지하철역에서 다가오는 열차의 실시간 정보를 최대 5개 가져옵니다.
  /// - Parameter targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  /// - Returns: 실시간 도착정보의 배열
  func fetch(targetStation: StationInfo?, directionStationID: String?) async -> [TrainInfo] {
    guard let targetStation, let directionStationID else { return [] }

    do {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.trainDestination.contains(StationInfo.findStationName(from: directionStationID))
      }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return []
    }
  }

  /// 특정 지하철역을 기준으로, 가야하는 방향으로 다가오는 열차의 실시간 정보를 최대 5개 가져옵니다.
  /// - Parameter targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  /// - Returns: 실시간 도착정보의 배열
  func fetchFar(targetStation: StationInfo?, directionStationID: String?) async -> [TrainInfo] {
    guard let targetStation, let directionStationID else { return [] }

    do {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.trainDestination.contains(StationInfo.findStationName(from: directionStationID))
      }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return []
    }
  }

  /// 특정 지하철역을 기준으로, 접근하는 모든 방향의 실시간 도착정보를 배열 형태로 가져옵니다.
  private func fetch(stationID: String) async throws -> ArrivalInfo {
    let stationName = StationInfo.findStationName(from: stationID)

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

    let decodedData = try JSONDecoder().decode(ArrivalInfo.self, from: data)

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
