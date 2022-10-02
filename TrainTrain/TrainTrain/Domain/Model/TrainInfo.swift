import Foundation

struct TrainInfo: Decodable, Identifiable {

  /// 지하철 호선 ID
  let subwayLineID: String
  /// 도착지 방면 (성수행 - 구로디지털단지방면)
  let trainDestination: String
  /// 이전 지하철역 ID
  let previousStationID: String
  /// 다음 지하철역 ID
  let nextStationID: String
  /// 지하철역 ID
  let stationID: String
  /// 지하철역명
  let stationName: String
  /// 열차 종류 (급행, ITX) - 일반 지하철인 경우, 'normal' 이 나옵니다.
  let trainType: TrainType
  /// 열차 도착 예정 시간 (단위:초) - Estimated Time of Arrival
  let eta: String
  /// 종착 지하철역ID
  let terminusStationID: String
  /// 종착 지하철역명
  let terminusStationName: String
  /// 열차 도착정보를 생성한 시각
  let createdAt: String
  /// 첫 번째 도착 메세지 (전역 진입, 전역 도착 등)
  let firstMessage: String
  /// 두 번째 도착 메세지 (종합운동장 도착, 12분 후 (광명사거리) 등)
  let secondMessage: String
  /// 도착코드 (0:진입, 1:도착, 2:출발, 3:전역출발, 4:전역진입, 5:전역도착, 99:운행중)
  let arrivalCode: String

  /// Identifier
  var id: String {
    "\(stationName)-\(eta)"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subwayLineID = try container.decode(String.self, forKey: .subwayLineID)
    trainDestination = try container.decode(String.self, forKey: .trainDestination)
    previousStationID = try container.decode(String.self, forKey: .previousStationID)
    nextStationID = try container.decode(String.self, forKey: .nextStationID)
    stationID = try container.decode(String.self, forKey: .stationID)
    stationName = try container.decode(String.self, forKey: .stationName)
    eta = try container.decode(String.self, forKey: .eta)
    terminusStationID = try container.decode(String.self, forKey: .terminusStationID)
    terminusStationName = try container.decode(String.self, forKey: .terminusStationName)
    createdAt = try container.decode(String.self, forKey: .createdAt)
    firstMessage = try container.decode(String.self, forKey: .firstMessage)
    secondMessage = try container.decode(String.self, forKey: .secondMessage)
    arrivalCode = try container.decode(String.self, forKey: .arrivalCode)

    let trainTypeString = try container.decode(String?.self, forKey: .trainType)
    trainType = convertTrainType(of: trainTypeString)

    func convertTrainType(of string: String?) -> TrainType {
      switch string {
      case "급행": return .express
      case "itx": return .itx
      default: return .normal
      }
    }
  }

  private enum CodingKeys: String, CodingKey {
    case subwayLineID = "subwayId"
    case trainDestination = "trainLineNm"
    case previousStationID = "statnFid"
    case nextStationID = "statnTid"
    case stationID = "statnId"
    case stationName = "statnNm"
    case trainType = "btrainSttus"
    case eta = "barvlDt"
    case terminusStationID = "bstatnId"
    case terminusStationName = "bstatnNm"
    case createdAt = "recptnDt"
    case firstMessage = "arvlMsg2"
    case secondMessage = "arvlMsg3"
    case arrivalCode = "arvlCd"
  }
}
