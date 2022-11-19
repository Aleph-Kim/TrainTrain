import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/5/"

  /// 특정 지하철역을 기준으로, 이전 지하철역에서 다가오는 열차들과, 특정 지하철역을 떠난 열차들의 리스트를 배열 형태로 가져옵니다.
  ///
  /// 특정 지하철역을 떠난 경우도 포괄하기 위해, ``fetch(targetStation:directionStationID:)`` 메서드 한 번으로
  /// 방금 떠난 열차들도 보여줄 수 있도록 만들었습니다.
  ///
  /// - Parameters:
  ///   - targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  ///   - directionStationID: 진행하고자 하는 방향의 첫 번째 지하철역 ID
  ///
  /// - Returns: 실시간 도착정보의 배열
  func fetch(targetStation: StationInfo?, directionStationID: String?) async -> [TrainInfo] {
    guard let targetStation, let directionStationID else { return [] }

    do {
      let arrivalInfo = try await fetch(stationID: targetStation.stationID)
      let nextInfo = try await fetch(stationID: directionStationID)

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.trainDestination.contains(StationInfo.findStationName(from: directionStationID))
          && $0.secondMessage != targetStation.stationName // 중복 방지
      }

      let nextList = nextInfo.realtimeArrivalList.filter {
        $0.secondMessage == targetStation.stationName // 메시지2가 타겟역인 경우만 가져옴 (떠났다는 뜻)
      }

      return nextList + filteredList
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
