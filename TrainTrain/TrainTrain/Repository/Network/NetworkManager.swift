import Foundation

struct NetworkManager {

  private let baseURLString = "http://swopenAPI.seoul.go.kr/api/subway/4448686271696d6f35337449787245/json/realtimeStationArrival/0/2/"

  /// 특정 지하철역을 기준으로, 이전 지하철역에서 다가오는 열차의 실시간 정보를 최대 2개 가져옵니다.
  /// - Parameter targetStation: 실시간 도착정보의 기준이 되는 지하철역 타입
  /// - Returns: 실시간 도착정보의 배열
  /// TODO: - ID로 역을 찾아서 네트워크 통신하는 로직 구현하기
  func fetch(targetStation: StationInfo?) async -> [TrainInfo] {
    guard let targetStation else { return [] }
    var targetStationName = targetStation.stationName
    guard var previousStationName = targetStation.previousStationName else { return [] }

    if targetStationName.last == "역" {
      targetStationName.removeLast()
    }

    if previousStationName.last == "역" {
      previousStationName.removeLast()
    }

    do {
      let arrivalInfo = try await fetch(stationName: targetStationName)
      print("📡 통신 상태값 -> status: \(arrivalInfo.errorMessage.code), message: \(arrivalInfo.errorMessage.message), total: \(arrivalInfo.errorMessage.total)")

      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.secondMessage == previousStationName
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
  func fetchFar(targetStation: StationInfo) async -> [TrainInfo] {
    var targetStationName = targetStation.stationName
    guard var nextStationName = targetStation.nextStationName else { return [] }

    if targetStationName.last == "역" {
      targetStationName.removeLast()
    }

    if nextStationName.last == "역" {
      nextStationName.removeLast()
    }

    do {
      let arrivalInfo = try await fetch(stationName: targetStationName)
      let filteredList = arrivalInfo.realtimeArrivalList.filter {
        $0.trainDestination.contains(nextStationName)
      }
      return filteredList
    } catch {
      print("⚠️ 통신 중 에러 발생 -> \(error)")
      return []
    }
  }

  /// 특정 지하철역을 기준으로, 접근하는 모든 방향의 실시간 도착정보를 배열 형태로 가져옵니다.
  private func fetch(stationName: String) async throws -> ArrivalInfo {
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
