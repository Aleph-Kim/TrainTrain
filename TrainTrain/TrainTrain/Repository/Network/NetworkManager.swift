import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/2/"

  /// 특정 지하철역을 기준으로, 이전 지하철역에서 다가오는 열차의 실시간 정보를 최대 2개 가져옵니다.
  /// - Parameter targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  /// - Returns: 실시간 도착정보의 배열
  func fetch(targetStation: StationInfo?, directionStationID: String?) async -> [TrainInfo] {
    guard let targetStation, let directionStationID else { return [] }

    var previousStationID = ""

    if [targetStation.upperStationID_1, targetStation.upperStationID_2].contains(directionStationID) { // 상행 확인
      if let lower1 = targetStation.lowerStationID_1 { // 이전역이 있다면
        previousStationID = lower1
      }
    } else if [targetStation.lowerStationID_1, targetStation.lowerStationID_2].contains(directionStationID) { // 하행 확인
      if let upper1 = targetStation.upperStationID_1 { // 이전역이 있다면
        previousStationID = upper1
      }
    }

    do {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)
      print("📡 통신 상태값 -> status: \(arrivalInfo.errorMessage.code), message: \(arrivalInfo.errorMessage.message), total: \(arrivalInfo.errorMessage.total)")

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        // 이전역 이름을 기준으로 필터링
        print($0.secondMessage)
        return $0.secondMessage == StationInfo.fetchStationName(from: previousStationID)
      }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return []
    }
  }

  /// 특정 지하철역을 기준으로, 가야하는 방향으로 다가오는 열차의 실시간 정보를 최대 2개 가져옵니다.
  /// - Parameter targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  /// - Returns: 실시간 도착정보의 배열
  func fetchFar(targetStation: StationInfo?, directionStationID: String?) async -> [TrainInfo] {
    guard let targetStation, let directionStationID else { return [] }

    do {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)
      print("📡 통신 상태값 -> status: \(arrivalInfo.errorMessage.code), message: \(arrivalInfo.errorMessage.message), total: \(arrivalInfo.errorMessage.total)")

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.trainDestination.contains(StationInfo.fetchStationName(from: directionStationID))
      }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return []
    }
  }

  /// 특정 지하철역을 기준으로, 접근하는 모든 방향의 실시간 도착정보를 배열 형태로 가져옵니다.
  private func fetch(stationID: String) async throws -> ArrivalInfo {
    let stationName = StationInfo.fetchStationName(from: stationID)

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
