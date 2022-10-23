import Foundation

struct StationInfo: Equatable {

  /// 지하철 호선 ID
  let subwayLineID: String
  /// 지하철역 ID
  let stationID: String
  /// 지하철역명
  let stationName: String
  /// 하행 지하철역 ID
  let lowerStationID_1: String?
  let lowerStationETA_1: Int?
  let lowerStationID_2: String?
  let lowerStationETA_2: Int?
  /// 상행 지하철역 ID
  let upperStationID_1: String?
  let upperStationETA_1: Int?
  let upperStationID_2: String?
  let upperStationETA_2: Int?

  init(subwayLineID: Any,
       stationID: Any,
       stationName: Any,
       lowerStationID_1: Any?,
       lowerStationETA_1: Any?,
       lowerStationID_2: Any?,
       lowerStationETA_2: Any?,
       upperStationID_1: Any?,
       upperStationETA_1: Any?,
       upperStationID_2: Any?,
       upperStationETA_2: Any?
  ) {
    self.subwayLineID = "\(subwayLineID)"
    self.stationID = "\(stationID)"
    self.stationName = "\(stationName)" + "역"
    self.lowerStationID_1 = lowerStationID_1 != nil ? "\(lowerStationID_1!)" : nil
    self.lowerStationETA_1 = lowerStationETA_1 != nil ? lowerStationETA_1 as? Int : nil
    self.lowerStationID_2 = lowerStationID_2 != nil ? "\(lowerStationID_2!)" : nil
    self.lowerStationETA_2 = lowerStationETA_2 != nil ? lowerStationETA_2 as? Int : nil
    self.upperStationID_1 = upperStationID_1 != nil ? "\(upperStationID_1!)" : nil
    self.upperStationETA_1 = upperStationETA_1 != nil ? upperStationETA_1 as? Int : nil
    self.upperStationID_2 = upperStationID_2 != nil ? "\(upperStationID_2!)" : nil
    self.upperStationETA_2 = upperStationETA_2 != nil ? upperStationETA_2 as? Int : nil
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
    
  func makeThreeStationList(stationInfo: StationInfo, directionStationID: String) -> (Self, Self?, Self?) {
    
    if let prevStation = Self.allStationList.first(where:{
      return $0.stationID != directionStationID &&
          ($0.lowerStationID_1 == stationInfo.stationID ||
           $0.lowerStationID_2 == stationInfo.stationID ||
           $0.upperStationID_1 == stationInfo.stationID ||
           $0.upperStationID_2 == stationInfo.stationID)
    }) {
      if let prevPrevStation = Self.allStationList.first(where:{
        return $0.stationID != directionStationID &&
            ($0.lowerStationID_1 == prevStation.stationID ||
             $0.lowerStationID_2 == prevStation.stationID ||
             $0.upperStationID_1 == prevStation.stationID ||
             $0.upperStationID_2 == prevStation.stationID)
      }) {
        return (stationInfo, prevStation, prevPrevStation)
      } else {
        return (stationInfo, prevStation, nil)
      }
    } else {
      return (stationInfo, nil, nil)
    }
  }
}
