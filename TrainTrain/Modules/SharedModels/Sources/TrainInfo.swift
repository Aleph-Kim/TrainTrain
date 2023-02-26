import Foundation

public struct TrainInfo: Decodable, Identifiable, Equatable {

  /// 지하철 호선 ID
  public let subwayLineID: String
  /// 도착지 방면 (성수행 - 구로디지털단지방면)
  public let trainDestination: String
  /// 이전 지하철역 ID
  public var previousStationID: String
  /// 다음 지하철역 ID
  public var nextStationID: String
  /// 지하철역 ID
  public var stationID: String
  /// 지하철역명
  public let stationName: String
  /// 열차 종류 (급행, ITX) - 일반 지하철인 경우, 'normal' 이 나옵니다.
  public let trainType: TrainType
  /// 열차 도착 예정 시간 (단위:초) - Estimated Time of Arrival
  public var eta: String
  /// 종착 지하철역ID
  public let terminusStationID: String
  /// 종착 지하철역명
  public let terminusStationName: String
  /// 열차 도착정보를 생성한 시각
  public var createdAt: String
  /// 첫 번째 도착 메세지 - 진입, 도착, 출발과 같은 구체적 상태 또는 분/초로 표시한 ETA 를 표시합니다.
  public var firstMessage: String
  /// 두 번째 도착 메세지 - 직전 역의 이름을 표시합니다.
  public var secondMessage: String?
  /// 도착코드 (0:진입, 1:도착, 2:출발, 3:전역출발, 4:전역진입, 5:전역도착, 99:운행중)
  public var arrivalState: ArrivalState

  /// Identifier
  public let id: String

  public init(
    subwayLineID: String,
    trainDestination: String,
    previousStationID: String,
    nextStationID: String,
    stationID: String,
    stationName: String,
    trainType: TrainType,
    eta: String,
    terminusStationID: String,
    terminusStationName: String,
    createdAt: String,
    firstMessage: String,
    secondMessage: String,
    arrivalState: ArrivalState,
    id: String
  ) {
    self.subwayLineID = subwayLineID
    self.trainDestination = trainDestination
    self.previousStationID = previousStationID
    self.nextStationID = nextStationID
    self.stationID = stationID
    self.stationName = stationName
    self.trainType = trainType
    self.eta = eta
    self.terminusStationID = terminusStationID
    self.terminusStationName = terminusStationName
    self.createdAt = createdAt
    self.firstMessage = firstMessage
    self.secondMessage = secondMessage
    self.arrivalState = arrivalState
    self.id = id
  }

  public init(
    from trainInfo: TrainInfo,
    eta: String
  ) {
    self.subwayLineID = trainInfo.subwayLineID
    self.trainDestination = trainInfo.trainDestination
    self.previousStationID = trainInfo.previousStationID
    self.nextStationID = trainInfo.nextStationID
    self.stationID = trainInfo.stationID
    self.stationName = trainInfo.stationName
    self.trainType = trainInfo.trainType
    self.eta = eta
    self.terminusStationID = trainInfo.terminusStationID
    self.terminusStationName = trainInfo.terminusStationName
    self.createdAt = trainInfo.createdAt
    self.firstMessage = trainInfo.firstMessage
    self.secondMessage = trainInfo.secondMessage
    self.arrivalState = trainInfo.arrivalState
    self.id = trainInfo.id
  }

  public init(from decoder: Decoder) throws {
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
    secondMessage = try? container.decode(String.self, forKey: .secondMessage)
    
    id = try container.decode(String.self, forKey: .trainNumber)

    let trainTypeMessage = try container.decode(String?.self, forKey: .trainType)
    trainType = convertTrainType(of: trainTypeMessage)

    let arrivalCodeMessage = try container.decode(String.self, forKey: .arrivalCode)
    arrivalState = convertArrivalState(of: arrivalCodeMessage)

    func convertTrainType(of message: String?) -> TrainType {
      switch message {
      case "급행": return .express
      case "itx": return .itx
      default: return .normal
      }
    }

    func convertArrivalState(of message: String) -> ArrivalState {
      ArrivalState(rawValue: message) ?? .driving
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
    case trainNumber = "btrainNo"
  }

  public enum ArrivalState: String, CaseIterable {
    /// 0: 진입
    case approaching = "0"
    /// 1: 도착
    case arrived = "1"
    /// 2: 출발
    case departed = "2"

    /// 4: 전역 진입
    case previousApproaching = "4"
    /// 5: 전역 도착
    case previousArrived = "5"
    /// 3: 전역 출발
    case previousDeparted = "3"

    /// 99: 운행중
    case driving = "99"
  }
}

public extension TrainInfo {
  var isArrived: Bool {
    return Int(eta) == 0
  }

  var isNotArrived: Bool {
    return !isArrived
  }
}
