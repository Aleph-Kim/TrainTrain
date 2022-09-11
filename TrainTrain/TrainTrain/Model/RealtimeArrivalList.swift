import Foundation

struct RealtimeArrivalList: Decodable {

  /// - Note: 지하철 호선 ID
  let subwayLineID: String
  /// - Note: 도착지 방면 (성수행 - 구로디지털단지방면)
  let trainDestination: String
  /// - Note: 이전 지하철역 ID
  let previousStationID: String
  /// - Note: 다음 지하철역 ID
  let nextStationID: String
  /// - Note: 지하철역 ID
  let stationID: String
  /// - Note: 지하철역명
  let stationName: String
  /// - Note: 열차 종류 (급행, ITX) - 일반 지하철인 경우, nil 나옵니다.
  let trainType: String?
  /// - Note: 열차 도착 예정 시간 (단위:초)
  let eta: String
  /// - Note: 종착 지하철역ID
  let lastStationID: String
  /// - Note: 종착 지하철역명
  let lastStationName: String
  /// - Note: 열차 도착정보를 생성한 시각
  let createdAt: String
  /// - Note: 첫 번째 도착 메세지 (전역 진입, 전역 도착 등)
  let firstMessage: String
  /// - Note: 두 번째 도착 메세지 (종합운동장 도착, 12분 후 (광명사거리) 등)
  let secondMessage: String
  /// - Note: 도착코드 (0:진입, 1:도착, 2:출발, 3:전역출발, 4:전역진입, 5:전역도착, 99:운행중)
  let arrivalCode: String

  private enum CodingKeys: String, CodingKey {
    case subwayLineID = "subwayId"
    case trainDestination = "trainLineNm"
    case previousStationID = "statnFid"
    case nextStationID = "statnTid"
    case stationID = "statnId"
    case stationName = "statnNm"
    case trainType = "btrainSttus"
    case eta = "barvlDt"
    case lastStationID = "bstatnId"
    case lastStationName = "bstatnNm"
    case createdAt = "recptnDt"
    case firstMessage = "arvlMsg2"
    case secondMessage = "arvlMsg3"
    case arrivalCode = "arvlCd"
  }
}
