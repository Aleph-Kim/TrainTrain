import Foundation

struct StationInfo: Equatable {

  /// 지하철 호선 ID
  let subwayLineID: String
  /// 지하철역 ID
  let stationID: String
  /// 지하철역명
  let stationName: String
  /// 하행 방향의 첫 번째 지하철역 ID
  let lowerStationID_1: String?
  /// 하행 방향의 첫 번째 지하철역 까지의 예상 소요 시간 (초) - 네이버 지도 기준
  let lowerStationETA_1: Int?
  /// 하행 방향의 두 번째 지하철역 ID (ex. 1호선 구로역, 2호선 성수역, 신도림역, 5호선 강동역, 6호선 응암역)
  let lowerStationID_2: String?
  /// 하행 방향의 두 번째 지하철역 까지의 예상 소요 시간 (초) - 네이버 지도 기준
  let lowerStationETA_2: Int?
  /// 상행 방향의 첫 번째 지하철역 ID
  let upperStationID_1: String?
  /// 상행 방향의 첫 번째 지하철역 까지의 예상 소요 시간 (초) - 네이버 지도 기준
  let upperStationETA_1: Int?
  /// 상행 방향의 두 번째 지하철역 ID (221023 DB 기준으로 존재하지 않음)
  let upperStationID_2: String?
  /// 상행 방향의 두 번째 지하철역 까지의 예상 소요 시간 (초) - 네이버 지도 기준
  let upperStationETA_2: Int?

  init(subwayLineID: Any,
       stationID: Any,
       stationName: Any,
       lowerStationID_1: Any,
       lowerStationETA_1: Any,
       lowerStationID_2: Any,
       lowerStationETA_2: Any,
       upperStationID_1: Any,
       upperStationETA_1: Any,
       upperStationID_2: Any,
       upperStationETA_2: Any
  ) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)" // + "역"
    self.lowerStationID_1 = "\(lowerStationID_1)".isEmpty ? nil : "\(lowerStationID_1)"
    self.lowerStationID_2 = "\(lowerStationID_2)".isEmpty ? nil : "\(lowerStationID_2)"
    self.upperStationID_1 = "\(upperStationID_1)".isEmpty ? nil : "\(upperStationID_1)"
    self.upperStationID_2 = "\(upperStationID_2)".isEmpty ? nil : "\(upperStationID_2)"
    self.lowerStationETA_1 = "\(lowerStationETA_1)".isEmpty ? nil : lowerStationETA_1 as? Int
    self.lowerStationETA_2 = "\(lowerStationETA_2)".isEmpty ? nil : lowerStationETA_2 as? Int
    self.upperStationETA_1 = "\(upperStationETA_1)".isEmpty ? nil : upperStationETA_1 as? Int
    self.upperStationETA_2 = "\(upperStationETA_2)".isEmpty ? nil : upperStationETA_2 as? Int
  }

  /// plist 에 포함된 모든 노선의 지하철 역 정보의 배열
  static let allStationList: [StationInfo] = {
    let path = Bundle.main.path(forResource: "StationList221023", ofType: "plist")!
    let arrOfDict = NSArray(contentsOfFile: path)! as! [[String: Any]]
    let stations = arrOfDict.map {
      StationInfo(
        subwayLineID: $0["SUBWAY_ID"]!,
        stationID: $0["STATN_ID"]!,
        stationName: $0["STATN_NM"]!,
        lowerStationID_1: $0["LOWER_STATN_ID_1"]!,
        lowerStationETA_1: $0["LOWER_STATN_ETA_1"]!,
        lowerStationID_2: $0["LOWER_STATN_ID_2"]!,
        lowerStationETA_2: $0["LOWER_STATN_ETA_2"]!,
        upperStationID_1: $0["UPPER_STATN_ID_1"]!,
        upperStationETA_1: $0["UPPER_STATN_ETA_1"]!,
        upperStationID_2: $0["UPPER_STATN_ID_2"]!,
        upperStationETA_2: $0["UPPER_STATN_ETA_2"]!
      )
    }
    return stations
  }()

  /// 특정 호선의 모든 역 정보를 배열 형태로 가져오기
  static func fetchStationList(of line: SubwayLine) -> [StationInfo] {
    Self.allStationList.filter { $0.subwayLineID == line.id }
  }
  
  /// 역의 ID 를 통해 역의 이름을 찾아 리턴합니다.
  static func findStationName(from stationID: String) -> String {
    Self.allStationList.first(where: { $0.stationID == stationID })?.stationName ?? ""
  }

  /// 역의 ID 를 통해 역타입(StationInfo)을 리턴합니다.
  /// 존재하지 않는 ID 라면, `nil` 을 리턴합니다.
  static func findStationInfo(from stationID: String) -> StationInfo {
    Self.allStationList.first(where: { $0.stationID == stationID })!
  }
}
